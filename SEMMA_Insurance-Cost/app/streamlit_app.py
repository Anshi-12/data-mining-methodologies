"""SEMMA hand-off demo — insurance charge estimator. Run: streamlit run app/streamlit_app.py (from the project folder)."""
import pathlib, joblib, pandas as pd, streamlit as st

ROOT = pathlib.Path(__file__).resolve().parents[1]
art = joblib.load(ROOT / "models" / "insurance_model.joblib")

def modify(d):
    d = d.copy()
    d["smoker_flag"] = (d["smoker"] == "yes").astype(int)
    d["obese"] = (d["bmi"] >= 30).astype(int)
    d["smoker_obese"] = d["smoker_flag"] * d["obese"]
    d["smoker_bmi"] = d["smoker_flag"] * d["bmi"]
    d["age_sq"] = d["age"] ** 2
    return d

st.set_page_config(page_title="Insurance Cost Estimator", page_icon="🏥")
st.title("🏥 Annual Medical Insurance Cost Estimator")
age = st.slider("Age", 18, 64, 35); bmi = st.slider("BMI", 15.0, 55.0, 27.0, 0.1)
children = st.selectbox("Children", [0, 1, 2, 3, 4, 5]); smoker = st.radio("Smoker", ["no", "yes"], horizontal=True)
sex = st.radio("Sex", ["female", "male"], horizontal=True); region = st.selectbox("Region", ["northeast", "northwest", "southeast", "southwest"])
row = pd.DataFrame([dict(age=age, sex=sex, bmi=bmi, children=children, smoker=smoker, region=region)])
pred = art["model"].predict(modify(row)[art["features"]])[0]
st.metric("Estimated annual charges", f"${pred:,.0f}")
st.caption("Educational demo built on a public Kaggle dataset — not for real pricing.")
