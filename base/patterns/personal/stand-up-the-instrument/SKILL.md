---
name: stand-up-the-instrument
description: >
  Use when a team is arguing about a fuzzy, intermittent system behavior from anecdote
  ("it got slow", "the model got dumber", "we're burning too many tokens") and nobody
  has data. Before theorizing or "fixing", build the smallest local instrument that
  records the behavior, then let the data settle the argument.
id: stand-up-the-instrument
category: workflow
invocation: user
aliases: [tokometer-pattern, measure-first, instrument-the-hunch]
triggers: [intermittent, "got slow", "got dumber", flaky, "it depends", capacity, no data, hunch]
source: base
status: active
related: [data-diode-list-control]
visibility: public
---

# Stand Up the Instrument

## Intent

Some problems are debated endlessly because they're **intermittent and unmeasured** —
everyone has an anecdote, no one has a timeline. The reflex is to theorize or to "fix"
blind. This pattern says: **the instrument is the argument.** Build the smallest thing
that records the behavior locally, run it while working normally, and let a week of data
name the cause. The harness *is* the deliverable (a blog, a decision, a settled debate),
not just a means to a fix.

## Structure

1. **Name the rival hypotheses** you're choosing between (e.g. down-routing vs. context
   rot vs. quota vs. a client crash). The instrument must be able to *distinguish* them.
2. **Find the cheapest existing signal** the system already emits (a log line, a
   file, an existing exporter) before building new collection. Read what's there.
3. **Record locally, timestamped, zero-egress.** A ledger + events, on a shared clock.
4. **Classify, don't just log** — label each event with the hypothesis it supports, so
   the report answers "which one" not "here's raw data to interpret by hand."
5. **Correlate with the obvious external variable** (time-of-day, load, session length).
6. **Report on a cadence** (daily/weekly) that turns the timeline into a decision.

## House adaptation

- **Reuse the same shape every time**: ingest → normalize → classify → timeline+summary.
  Tokometer (token spend), Routometer (Copilot degradation) are the same instrument
  pointed at different signals.
- **Prefer the signal the system already writes** over new probes — a Trace-level log
  beat building an OTel pipeline.
- **The instrument settles arguments precisely because it's boring and local** — no
  cloud, no auth, no one to distrust. "Overnight succeeds, daytime fails" ends the debate.

## Reference instantiation

`coder/tokometer` (AI token spend across harnesses), `routometer` + the `dot-copilot`
field kit (which of four mechanisms degrades Copilot, correlated to time-of-day).

## Anti-patterns / when NOT

- When the behavior is deterministic and reproducible — just debug it; don't build a
  meter. This is for the *intermittent, capacity/context/time-dependent* class.
- Don't let the instrument become the project forever — it exists to settle an argument
  and set a strategy; once it has, stop polishing it.
