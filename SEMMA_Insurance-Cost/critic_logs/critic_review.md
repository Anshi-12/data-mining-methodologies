# SEMMA — Critic Review Log
**Critic:** Claude (Anthropic) with the persona in `docs/critic_prompt_template.md`, adapted to "the leading authority on SEMMA and SAS Enterprise Miner". Fixes listed are present in the final notebook.

---
## Sample
### Round 1
- **MAJOR** — A plain random split. With ~20% smokers driving the expensive tail, stratify on smoker × charge quartile.
- **MAJOR** — The exact duplicate row must be removed *before* partitioning, otherwise it can land in both train and test.
- **MINOR** — Show that partitions are representative (statistical test, not just eyeballing).
- *Score: 5/10*
### Round 2
- Fixed: stratified 60/20/20, duplicate removed, KS/χ² tests (all p > 0.05), SAS node mapping table, explicit argument for using all rows rather than down-sampling.
- *Score: 9/10*

## Explore
### Round 1
- **MINOR** — Exploration was on the full data → restrict to train only.
- **MAJOR** — The smoker × BMI interaction is visible in the scatter plot but not quantified → pivot table (smoker & BMI≥30 mean ≈ $42k vs ≈ $21.7k) and non-parametric tests.
- *Score: 6/10*
### Round 2
- Fixed; outliers investigated (97% smokers → real cases, kept).
- *Score: 9/10*

## Modify
### Round 1
- **MINOR** — Feature rationale must point back to Explore findings → table added.
- **MINOR** — Variable-selection step (SAS Variable Selection node) missing → mutual information check added.
- *Score: 7/10*
### Round 2
- *Score: 9/10*

## Model
### Round 1
- **MAJOR** — The only engineered regression used a log target. The critic asked: "Explore suggested the log transform; where is the evidence it helps the *model*?" → added the same regression on the dollar target as a separate candidate.
- **MINOR** — Include a raw-input regression to measure the value of the Modify step.
- *Score: 6/10*
### Round 2
- Result after the fix: engineered dollar-target regression became the **champion** (validation RMSE $4,279, R² 0.860), log-target version was worst (R² 0.453). The critic's challenge changed the outcome of the project.
- *Score: 9/10*

## Assess
### Round 1
- **MAJOR** — The draft conclusion said "tree ensembles give the lowest error" — false after the Model revision. Conclusions must be regenerated from the comparison table.
- **MINOR** — Add decile assessment (SAS lift-style) and error analysis by segment.
- *Score: 5/10*
### Round 2
- Fixed: champion explained with dollar coefficients; decile table shows monotone ranking (top decile 3.1× average); test R² 0.875; rejected log hypothesis explained.
- *Score: 9/10*

---
### Note for the student
Append a GPT-5 round using the same template if you want a second independent critic.
