---
name: explain-from-the-record
description: >
  Use when an AI or algorithmic system (LLM agent, ML model, contextual bandit, vision pipeline,
  or a deterministic scoring algorithm) produces an output that affects a person, an asset or a
  control, and someone will later ask why. Write a decision record at the moment of the output,
  then render every explanation for its audience from that record. The model's reasoning text
  and its own summary go into the record as items to monitor, and never become the explanation.
id: explain-from-the-record
category: llm-integration
invocation: model
aliases: [decision-record, render-from-record, layered-explainability, explanation-renderer]
triggers: [explainability, explain why, responsible AI, audit trail, adverse action, reason codes, contest, appeal, human review, agent said it did, chain of thought as explanation, OTel GenAI, decision log, provenance, SME validation, EU AI Act, ADMT]
source: base
license: null
origin-url: null
stance: null
status: active
related: [stand-up-the-instrument, data-diode-list-control, medallion-ingest-pipeline]
visibility: public
---

# Explain From the Record

## Intent

A system's output reaches an affected person, an operator or an auditor, and they ask why. The
cheapest answer is to ask the model, and its answer reads well. Reasoning-trace research and any
agent that runs long enough show that the model's account can omit what drove the output, cite a
real number for the wrong question, or give a reason the system never used. Explanations have to
come from something whose relation to the decision is known by construction: a record written
when the system acted.

## Structure

1. **Record at decision time.** One append-only decision record per consequential output, written
   before anything downstream acts on it. It holds the actor and the principal it acts for, the
   authority granted and used (the delegation chain at every hop), pinned versions (model, prompt
   hash, tools, policy, reason catalog), inputs and evidence by reference and hash with raw tool
   returns in governed storage, the output with reason codes, confidence and an out-of-scope
   flag, **which rule fired** as well as what it decided, the human action with its basis, stated
   limits and redactions.
2. **Render per audience.** A renderer fills templates from a versioned reason catalog and the
   record's structured fields. It produces the affected person's notice, the operator's view and
   the auditor's full account. Model-written prose is allowed only in slots that cite a record
   item.
3. **Check every rendering.** Deterministic pointer check (every citation resolves to a record
   item whose hash still matches) and coverage check (every recorded reason appears, and no
   unrecorded reason does), both blocking. Then an advisory claim-level support check, then human
   sampling that includes cases where the system was wrong.
4. **Close the loop.** A contest route that freezes the record and the explanation as sent, routes
   to a reviewer with authority to overturn, and records the outcome in the same reason catalog.

Levels for placing a project, chosen by stage (Explore, Expand, Extract): L0 system transparency,
L1 disclosure that AI is involved, L2 the decision record, L3 the rendered explanation, L4 contest
and human review, L5 interpretability for research and debugging only.

## House adaptation

- **The trace is an alarm, never a certificate.** Keep the reasoning trace by reference for a
  monitor. Explanations assert why an outcome happened, which a trace cannot establish.
- **Record the rule that fired.** A claim engine that stores only its result invites the model to
  narrate a reason. This happened in the fitness coaching agent: the engine stored which plan card
  a ride claimed, and the report said "claimed on TSS" for a card with no TSS rule.
- **Record human judgement with provenance, and never record silence as agreement.** Mark each
  label `confirmed`, `redirected` or `unreviewed_accepted`, and count only the first two as ground
  truth. Ask with a deterministic prompt that lists facts and leaves out the system's guess, which
  would anchor the answer.
- **Human overrides are absolute.** Keep them in a sidecar the engine reads, with the engine's
  original claim beside the decision. If the engine could re-veto, the override would only work in
  the cases where it was not needed.
- **Deterministic and interpretable systems still get a per-run record.** A readable algorithm does
  not let a subject-matter expert check one particular result. A processing-time artifact for
  every score does, and it is what finally let experts validate a multi-source aggregate scoring
  algorithm against their own judgement. This departs lightly from Rudin (2019): choose an
  interpretable model where stakes are high, and write the record anyway.
- **A deterministic helper computes the answer, and the model paraphrases around it.**
- **An agent's completion report is never evidence of completion.** A check independent of the
  agent asks whether the artifact exists.
- **Content capture stays off in general observability.** Evidence goes to governed storage, and
  the record holds references and hashes. Traces and decision records get separate retention and
  access rules.
- **Records also assert more than they know** (`confidence: exact` on rows nobody measured), so
  reconcile derived fields against a primary source before rendering from them.
- **An ML policy that cannot be explained stays advisory**, with a rule-based control of record.

## Reference instantiation

- Article: [Building Explainability into an AI Project](https://scottrfrancis.wordpress.com/2026/09/16/building-explainability-into-an-ai-project/)
  (schema, reason catalog, renderings, check code, contest record, method by system type, OTel
  GenAI coverage, rules as of September 2026, planning checklist).
- `dynamic-training-calendar`: attributions sidecar (absolute human override), intents log with
  provenance, deterministic evening "What were you going for?" ask, sustained zone-time measure.
- `beaufort` `tools/fitness-report-verify`: artifact check independent of the agent.

## Anti-patterns / when NOT

- Shipping the reasoning trace or a post-hoc model summary as the explanation.
- Asking the model to explain itself more carefully instead of adding the missing fact to the
  record.
- Treating a grounding or citation score as proof the evidence was complete. Those checkers score
  against the context you hand them.
- Saliency maps presented as proof of what a vision model used.
- Feature attributions used to explain a bandit's exploration action.
- Auto-accepting a classification when the human does not reply.
- Logging prompt and response bodies into general-purpose observability.
- Not needed for low-stakes, reversible outputs an engineer can check directly. A trace is enough
  there.
