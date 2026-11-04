# Data Mining Process Methodologies — CRISP-DM · SEMMA · KDD
**Anshita Shah** · MSSE, San José State University · CMPE 255 Data Mining · Fall 2026

Three complete, end-to-end data-mining projects — one per methodology, each on a different dataset and problem type — with executed Colab notebooks, final reports, deployment artifacts, LLM critic logs, Medium articles and video walkthroughs.

| Methodology | Project | Problem type | Dataset | Notebook | Article | Video |
|---|---|---|---|---|---|---|
| **CRISP-DM** | [Telco Customer Churn](CRISP-DM_Telco-Churn/) | Classification + profit-optimal targeting | [Kaggle: Telco Customer Churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn) | [![Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Anshi-12/data-mining-methodologies/blob/main/CRISP-DM_Telco-Churn/CRISP_DM_Telco_Churn.ipynb) | [Medium](MEDIUM_LINK_CRISP) | [YouTube](YOUTUBE_LINK_CRISP) |
| **SEMMA** | [Medical Insurance Cost](SEMMA_Insurance-Cost/) | Regression | [Kaggle: Medical Cost Personal Dataset](https://www.kaggle.com/datasets/mirichoi0218/insurance) | [![Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Anshi-12/data-mining-methodologies/blob/main/SEMMA_Insurance-Cost/SEMMA_Insurance_Cost.ipynb) | [Medium](MEDIUM_LINK_SEMMA) | [YouTube](YOUTUBE_LINK_SEMMA) |
| **KDD** | [Grocery Market Basket](KDD_Grocery-Basket/) | Association rules (unsupervised) | [Groceries — arules R package, Hahsler et al. 2006](https://github.com/stedy/Machine-Learning-with-R-datasets/blob/master/groceries.csv) (also mirrored on Kaggle) | [![Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Anshi-12/data-mining-methodologies/blob/main/KDD_Grocery-Basket/KDD_Grocery_Basket.ipynb) | [Medium](MEDIUM_LINK_KDD) | [YouTube](YOUTUBE_LINK_KDD) |

## Headline results
| Project | Result |
|---|---|
| CRISP-DM | Test ROC-AUC **0.847**, recall **0.741**; targeting policy **+$37.5k** net value vs **–$26.6k** for "offer to everyone"; deployed as batch scorer + Streamlit app with PSI drift monitoring |
| SEMMA | Engineered linear regression beat RF/GBM: test **R² 0.875**, RMSE **$4,261**; log-target hypothesis from Explore rejected in Assess; matching SAS program |
| KDD | 592 mined rules → **112 validated** (Bonferroni-significant, 97% stable on hold-out); honest usefulness test vs popularity baseline |

## How the three methodologies differ
| | CRISP-DM | SEMMA | KDD |
|---|---|---|---|
| Phases | Business Understanding → Data Understanding → Data Preparation → Modeling → Evaluation → Deployment | Sample → Explore → Modify → Model → Assess | Selection → Preprocessing → Transformation → Data Mining → Interpretation/Evaluation |
| Starts from | a business problem | a defined technical problem | a domain and a discovery goal |
| Ends with | deployed, monitored solution | assessed champion model | validated, understandable knowledge |
| Distinctive emphasis here | cost model, profit-optimal threshold, deployment & monitoring | stratified partitioning, representativeness tests, model comparison | domain-driven cleaning, concept hierarchy, significance + hold-out validation |

## Repository structure
```
├── CRISP-DM_Telco-Churn/
│   ├── CRISP_DM_Telco_Churn.ipynb      executed notebook (all 6 phases, all generic tasks)
│   ├── report/CRISP-DM_Final_Report.md
│   ├── critic_logs/critic_review.md    LLM critic rounds per phase
│   ├── data/  figures/  models/        dataset, charts, churn_model.joblib + model_meta.json
│   └── app/                            streamlit_app.py, score_batch.py, features.py
├── SEMMA_Insurance-Cost/               same layout + sas/semma_insurance.sas
├── KDD_Grocery-Basket/                 same layout (models/rules.json)
├── docs/
│   └── critic_prompt_template.md       persona prompt used for every critique
└── requirements.txt
```

## Run locally
```bash
pip install -r requirements.txt
jupyter notebook                         # or open the Colab badges above
cd CRISP-DM_Telco-Churn && streamlit run app/streamlit_app.py
python app/score_batch.py data/Telco-Customer-Churn.csv call_list.csv
cd ../SEMMA_Insurance-Cost && streamlit run app/streamlit_app.py
cd ../KDD_Grocery-Basket && streamlit run app/streamlit_app.py
```
Notebooks load data from `data/` locally and fall back to this repository's raw GitHub URLs in Colab. Re-running a notebook regenerates its figures and models (`models/*.joblib` were saved with scikit-learn 1.9; re-run the notebook if your version differs).

## AI assistance & critique
Following the assignment, an LLM (Claude) was used to help generate code and to critique every phase through multiple revision rounds while role-playing a world-renowned authority on each methodology (prompt in `docs/critic_prompt_template.md`). All code was executed and outputs verified; every number in the reports and articles comes from the executed notebooks.
