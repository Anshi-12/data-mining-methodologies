# KDD — Critic Review Log
**Critic:** Claude (Anthropic) with the persona in `docs/critic_prompt_template.md`, adapted to "the leading authority on the KDD process (Fayyad et al.)". Fixes listed are present in the final notebook.

---
## Step 0–1 — Domain understanding & Selection
### Round 1
- **MAJOR** — No definition of what counts as *knowledge* here. KDD defines patterns as valid, novel, useful, understandable → success criteria must say how each is measured.
- *Score: 6/10*
### Round 2
- Fixed: Fisher + Bonferroni (valid), hold-out lift > 1 (valid on new data), non-staple consequents (novel), merchandising actions (useful), human-readable rules (understandable).
- *Score: 9/10*

## Step 2 — Preprocessing
### Round 1
- **MAJOR** — "shopping bags" is a checkout artefact, not a product; it appears in the top-10 items and would generate spurious rules → remove using domain knowledge.
- **MINOR** — Justify keeping single-item baskets (removing them inflates support and biases lift).
- *Score: 6/10*
### Round 2
- *Score: 9/10*

## Step 3 — Transformation
### Round 1
- **MAJOR** — Transformation was only one-hot encoding, which makes it indistinguishable from preprocessing. Add a real transformation: reduction and a concept hierarchy (item → department) for multi-level mining.
- **MAJOR** — No hold-out set, so validity on unseen data cannot be evaluated → 80/20 basket split.
- Bug found while executing: encoder fit only on discovery baskets failed on an item that only appears in hold-out → vocabulary now built from all baskets (names only; no statistics leak).
- *Score: 5/10*
### Round 2
- *Score: 9/10*

## Step 4 — Data Mining
### Round 1
- **MINOR** — Justify min-support choice; compare algorithms → Apriori vs FP-Growth with identical-output check and runtime curve.
- **MAJOR** — Department-level rules with up to 3 departments on each side were unreadable (133 rules) → restricted to department pairs (44 rules).
- *Score: 7/10*
### Round 2
- *Score: 9/10*

## Step 5 — Interpretation / Evaluation
### Round 1
- **MAJOR** — Ranked by confidence only; confidence is biased toward frequent consequents (whole milk). Use lift, leverage, conviction.
- **MAJOR** — 592 rules tested with no multiple-testing control → Bonferroni-corrected Fisher test.
- **MAJOR** — The recommender was presented without a baseline. When a popularity baseline was added, rules alone scored 14.9% hit-rate@5 vs 27.2% for popularity. The critic required reporting this honestly and adding a hybrid (27.6%).
- **MINOR** — Show the KDD iteration explicitly (loop back to tighten criteria for novelty).
- *Score: 5/10*
### Round 2
- Fixed all; 454/466 rules stay positive on hold-out; finding that rules are "precise but sparse" documented as a usefulness conclusion.
- *Score: 9/10*

---
### Note for the student
Append a GPT-5 round using the same template if you want a second independent critic.
