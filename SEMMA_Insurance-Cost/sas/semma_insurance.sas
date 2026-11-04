/*=====================================================================
  SEMMA in SAS — Medical Insurance Cost
  Author : Anshita Shah (SJSU MSSE, CMPE 255)
  Run in : SAS OnDemand for Academics / SAS Studio (free for students)
  Steps  : Sample -> Explore -> Modify -> Model -> Assess
  Setup  : upload data/insurance.csv to your SAS Studio home folder and
           set the path below.
=====================================================================*/
%let path = ~/insurance.csv;

/*------------------------------- SAMPLE ------------------------------*/
proc import datafile="&path" out=work.ins_raw dbms=csv replace;
  getnames=yes;
run;

/* remove the exact duplicate record (found in Python as rows 195/581) */
proc sort data=work.ins_raw out=work.ins nodupkey;
  by age sex bmi children smoker region charges;
run;

/* charge quartile used for stratification together with smoker */
proc rank data=work.ins out=work.ins groups=4;
  var charges; ranks charge_q;
run;
proc sort data=work.ins; by smoker charge_q; run;

/* 60/20/20 stratified partition: first draw 60% train */
proc surveyselect data=work.ins out=work.part1 samprate=0.6 outall seed=2026 method=srs;
  strata smoker charge_q;
run;
data work.train work.rest;
  set work.part1;
  if selected=1 then output work.train; else output work.rest;
  drop selected SelectionProb SamplingWeight;
run;
proc sort data=work.rest; by smoker charge_q; run;
proc surveyselect data=work.rest out=work.part2 samprate=0.5 outall seed=2026 method=srs;
  strata smoker charge_q;
run;
data work.valid work.test;
  set work.part2;
  if selected=1 then output work.valid; else output work.test;
  drop selected SelectionProb SamplingWeight;
run;

/* representativeness check */
data work.allparts; set work.train(in=a) work.valid(in=b) work.test(in=c);
  length partition $8; if a then partition='TRAIN'; else if b then partition='VALIDATE'; else partition='TEST';
run;
proc means data=work.allparts mean median maxdec=1; class partition; var age bmi charges; run;
proc freq data=work.allparts; tables partition*smoker / chisq nocol nopercent; run;

/*------------------------------- EXPLORE ------------------------------*/
proc means data=work.train n mean std min p50 max skew maxdec=2; var age bmi children charges; run;
proc sgplot data=work.train; histogram charges; density charges / type=kernel; title "Charges (train)"; run;
proc sgplot data=work.train; vbox charges / category=smoker; title "Charges by smoker"; run;
proc sgplot data=work.train; scatter x=bmi y=charges / group=smoker; refline 30 / axis=x; title "BMI vs charges"; run;
proc sgplot data=work.train; scatter x=age y=charges / group=smoker; title "Age vs charges"; run;
proc corr data=work.train spearman; var age bmi children charges; run;
proc npar1way data=work.train wilcoxon; class smoker; var charges; run;
title;

/*------------------------------- MODIFY -------------------------------*/
%macro modify(in, out);
data &out;
  set &in;
  smoker_flag  = (smoker = 'yes');
  obese        = (bmi >= 30);
  smoker_obese = smoker_flag * obese;
  smoker_bmi   = smoker_flag * bmi;
  age_sq       = age**2;
  male         = (sex = 'male');
run;
%mend;
%modify(work.train, work.train_m);
%modify(work.valid, work.valid_m);
%modify(work.test,  work.test_m);

/*------------------------------- MODEL --------------------------------*/
/* (1) Regression on raw inputs */
proc glmselect data=work.train_m valdata=work.valid_m;
  class region;
  model charges = age bmi children smoker_flag male region / selection=none;
  score data=work.valid_m out=work.p_reg_raw predicted=p_hat;
  score data=work.test_m  out=work.t_reg_raw predicted=p_hat;
run;

/* (2) Regression with Modify features (Python champion) */
proc glmselect data=work.train_m valdata=work.valid_m;
  class region;
  model charges = age age_sq bmi children smoker_flag obese smoker_obese smoker_bmi male region / selection=none;
  score data=work.valid_m out=work.p_reg_mod predicted=p_hat;
  score data=work.test_m  out=work.t_reg_mod predicted=p_hat;
run;

/* (3) Decision tree */
proc hpsplit data=work.train_m maxdepth=5;
  class smoker sex region;
  model charges = age bmi children smoker sex region;
  grow variance; prune costcomplexity;
  code file="%sysfunc(pathname(work))/tree_score.sas";
run;
data work.p_tree; set work.valid_m; %include "%sysfunc(pathname(work))/tree_score.sas"; p_hat = P_charges; run;

/* (4) Random forest (HP Forest) */
proc hpforest data=work.train_m maxtrees=300 seed=2026;
  target charges / level=interval;
  input age bmi children / level=interval;
  input smoker sex region / level=nominal;
  save file="%sysfunc(pathname(work))/forest.bin";
run;
proc hp4score data=work.valid_m;
  id charges; score file="%sysfunc(pathname(work))/forest.bin" out=work.p_rf;
run;
data work.p_rf; set work.p_rf; p_hat = P_charges; run;

/*------------------------------- ASSESS -------------------------------*/
%macro assess(ds, label);
data _null_; set &ds end=eof;
  retain sse sae sst n mean_y 0;
  err = charges - p_hat; sse + err**2; sae + abs(err); n + 1;
  if eof then do;
    rmse = sqrt(sse/n); mae = sae/n;
    put "ASSESS &label: RMSE=" rmse 10.1 " MAE=" mae 10.1 " n=" n;
  end;
run;
%mend;
%assess(work.p_reg_raw, Regression raw (validate));
%assess(work.p_reg_mod, Regression modified (validate));
%assess(work.p_tree,    Decision tree (validate));
%assess(work.p_rf,      HP Forest (validate));
%assess(work.t_reg_mod, Champion on TEST);

/* Decile assessment of the champion on test */
proc rank data=work.t_reg_mod out=work.dec groups=10; var p_hat; ranks decile; run;
proc means data=work.dec mean maxdec=0; class decile; var p_hat charges; title "Champion: mean predicted vs actual by decile (test)"; run;
title;
