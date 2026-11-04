# KDD Final Report — Grocery Market Basket Knowledge Discovery
**Author:** Anshita Shah · SJSU MSSE · CMPE 255 · November 2026
**Artifacts:** `KDD_Grocery_Basket.ipynb`, `models/rules.json`, `models/kdd_summary.json`, `app/`, `figures/`, `critic_logs/`

## Summary
Following the Fayyad et al. (1996) KDD process on 9,835 grocery transactions produced a knowledge base of **112 validated association rules** (18 with non-staple consequents), all statistically significant after Bonferroni correction and stable on a 20% hold-out set. The rules reveal a "meal preparation" mission (beef → root vegetables, lift 3.05) and a "fresh & chilled" mission (fruit/curd → yogurt). As a stand-alone recommender the rules are sparse (hit-rate@5 14.9% vs 27.2% popularity); a hybrid reaches 27.6%.

## 0. Domain & goals
Cross-selling and layout knowledge; patterns must be valid (Fisher + Bonferroni, hold-out lift > 1), novel (non-staple consequent), useful (actionable / evaluated), understandable (short rules).

## 1. Selection
9,835 baskets, 169 categories, item presence only.

## 2. Preprocessing
Normalised names; within-basket duplicates removed; "shopping bags" removed as non-product noise; 48 bag-only baskets dropped → 9,787; single-item baskets kept (avoid support inflation). Mean basket size ≈ 4.4.

## 3. Transformation
Boolean transaction matrix; items with support < 0.5% removed (119/169 kept); concept hierarchy item → 9 departments + other; 80/20 discovery/hold-out split (seed 7).

## 4. Data mining
| | Value |
|---|---|
| Algorithms | Apriori, FP-Growth (identical 322 itemsets at min_support 1%) |
| Item rules (lift > 1) | 592 |
| Department-pair rules (support ≥ 5%, lift > 1) | 44; top: household & care ↔ pantry (1.53), meat & fish ↔ pantry (1.50) |

## 5. Interpretation / Evaluation
| Filter | Rules |
|---|---|
| Fisher exact, Bonferroni α = 8.45e-05 | 468 |
| Redundancy pruning | 466 |
| Hold-out lift > 1 | 454 (97%); lift correlation 0.63 |
| Confidence ≥ 0.30, lift ≥ 1.5 | 112 |
| Non-staple consequent | 18 |

Top validated rules: {citrus fruit, other vegetables} → {root vegetables} (lift 3.67, hold-out 2.01); {other vegetables, tropical fruit} → {root vegetables} (3.17, 2.97); {beef} → {root vegetables} (3.05, 2.92); {tropical fruit, whole milk} → {yogurt} (2.59, 2.39); {curd} → {yogurt} (2.25, 2.62).

Iteration: first pass dominated by rules ending in whole milk / other vegetables → criteria tightened and novelty filter added.

## Use of knowledge
`rules.json` + `recommend()` + Streamlit app. Offline hit-rate@5 on 1,151 hold-out baskets: rules 14.9%, popularity 27.2%, hybrid 27.6%. Conclusion: knowledge best used for merchandising and as a re-ranking layer.

## Limitations
One month of data from one store; presence only (no quantities/prices); department mapping is keyword-based (some items fall in "other").
