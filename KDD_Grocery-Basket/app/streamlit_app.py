"""KDD — using the discovered knowledge. Run: streamlit run app/streamlit_app.py (from the project folder)."""
import json, pathlib, streamlit as st

ROOT = pathlib.Path(__file__).resolve().parents[1]
kb = json.load(open(ROOT / "models" / "rules.json"))
items = sorted({i for r in kb for i in r["antecedents"] + r["consequents"]})

def recommend(basket, k=5):
    basket, scores, why = set(basket), {}, {}
    for r in kb:
        if set(r["antecedents"]) <= basket:
            for c in r["consequents"]:
                if c not in basket and r["confidence"] * r["lift"] > scores.get(c, 0):
                    scores[c] = r["confidence"] * r["lift"]; why[c] = r
    return [(c, s, why[c]) for c, s in sorted(scores.items(), key=lambda x: -x[1])[:k]]

st.set_page_config(page_title="Frequently Bought Together", page_icon="🛒")
st.title("🛒 Frequently Bought Together")
st.caption(f"{len(kb)} validated association rules discovered with the KDD process")
basket = st.multiselect("Items in the basket", items, default=["root vegetables", "beef"])
recs = recommend(basket)
if not recs:
    st.info("No validated rule fires for this basket.")
for item, score, r in recs:
    st.write(f"**{item}** — because {{{', '.join(r['antecedents'])}}} → {{{', '.join(r['consequents'])}}} "
             f"(confidence {r['confidence']:.0%}, lift {r['lift']:.2f}, hold-out lift {r['holdout_lift']:.2f})")
