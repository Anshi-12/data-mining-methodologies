# SEMMA Final Report — Medical Insurance Cost
**Author:** Anshita Shah · SJSU MSSE · CMPE 255 · November 2026
**Artifacts:** `SEMMA_Insurance_Cost.ipynb`, `sas/semma_insurance.sas`, `models/insurance_model.joblib`, `models/model_meta.json`, `app/`, `figures/`, `critic_logs/`

## Summary
Annual medical charges were modelled for 1,337 de-duplicated policyholders using SEMMA. The champion — a linear regression with engineered smoker × BMI interaction features — achieved **test R² 0.875, RMSE $4,261, MAE $2,306**, beating random forest and gradient boosting on validation RMSE while remaining fully interpretable.

## S — Sample
- Roles: 6 inputs, `charges` target (SAS Input Data node).
- 1 exact duplicate removed before partitioning.
- All rows used (no down-sampling). Partition 60/20/20 = 802/267/268, stratified on smoker × charge quartile.
- Representativeness: KS and χ² vs train, all p > 0.05; smoker share 20.6/20.2/20.5%.

## E — Explore (train only)
- charges skew 1.54 → log(charges) −0.08.
- Spearman with charges: smoker 0.66, age 0.54.
- Interaction: smokers mean $21.7k (BMI < 30) vs $42.0k (BMI ≥ 30); non-smokers $8.3k vs $8.7k.
- Tests: smoker Mann–Whitney p ≈ 5×10⁻⁷⁹; region Kruskal–Wallis p = 0.16; sex p = 0.81.
- IQR outliers 9.9% of train, 97% smokers → kept.

## M — Modify
smoker_flag, obese (BMI ≥ 30), smoker_obese, smoker_bmi, age_sq; one-hot sex/region; standard scaling; candidate log target. Mutual information confirms age, smoker_bmi, smoker_flag, smoker_obese as top inputs.

## M — Model
| Model | Notes |
|---|---|
| Regression (raw inputs) | baseline for value of Modify |
| Regression (modified) | Ridge, dollar target |
| Regression (modified, log) | Ridge on log target + Duan smearing |
| Decision Tree | depth 5, min leaf 20 (CV) |
| Random Forest | max_features 0.5, min leaf 10 (CV) |
| Gradient Boosting | Huber loss, lr 0.03, depth 2, 300 trees (CV) |

## A — Assess
| Validation | RMSE | MAE | R² | MAPE |
|---|---|---|---|---|
| Regression (modified) | 4,279 | 2,349 | 0.860 | 26.5% |
| Random Forest | 4,392 | 2,539 | 0.852 | 29.3% |
| Gradient Boosting | 4,464 | 1,732 | 0.847 | 12.6% |
| Decision Tree | 4,808 | 2,855 | 0.823 | 31.3% |
| Regression (raw) | 5,963 | 4,184 | 0.727 | 45.2% |
| Regression (modified, log) | 8,442 | 4,667 | 0.453 | 34.8% |

- Test (champion): RMSE 4,261 · MAE 2,306 · R² 0.875 · MAPE 25.7%.
- Decile ranking monotone; top decile 3.13× average actual.
- Largest coefficients ($ per SD): smoker_bmi +5,519, smoker_obese +5,008, age_sq +3,635.
- Hypothesis rejected: log target (Explore) hurts the model because the smoker effect is an additive dollar surcharge.
- Residual error largest for non-smokers with unexpected high charges (conditions not in the data).

## Hand-off
`insurance_model.joblib` + score function; Streamlit estimator in `app/`. SEMMA has no deployment phase — production concerns would follow CRISP-DM Phase 6. SAS reproduction: `sas/semma_insurance.sas` (PROC SURVEYSELECT, SGPLOT, CORR, NPAR1WAY, GLMSELECT, HPSPLIT, HPFOREST).
