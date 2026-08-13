---
name: medallion-ingest-pipeline
description: >
  Use when designing any recurring ingestion that derives summaries/aggregates from raw
  source data (activity tracking, time tracking, sensor/telemetry disaggregation, any
  "fetch → summarize → aggregate" job). Land raw data untouched first (bronze), derive a
  queryable summary from it (silver), aggregate further if needed (gold) — each stage in
  its own error boundary, each stage self-healing from a backlog/watermark rather than
  needing the whole pipeline replayed.
id: medallion-ingest-pipeline
category: data-pipeline
invocation: model
aliases: [bronze-silver-gold, medallion-architecture, staged-ingest]
triggers: [ingest, ETL, pipeline, backfill, sync job, cron ingest, data pipeline, bronze silver gold, medallion, multi-source ingest, derived data, aggregation pipeline, disaggregation, telemetry, self-healing backlog, idempotent re-run]
source: base
license: null
origin-url: null
stance: null
status: active
related: [stand-up-the-instrument]
visibility: public
---

# Medallion Ingest Pipeline (Bronze / Silver / Gold)

## Intent

Any job that fetches from one or more sources and produces a derived summary faces the
same failure mode: write the raw fetch and the derived summary "at the same time" (one
function, two stores) and a partial failure — raw lands, derived write fails, or vice
versa — leaves permanently inconsistent state with no coordinating transaction to recover
it. The pattern: **don't write derived data alongside raw data — derive it from raw data
that's already durably landed**, in a strict sequence, so a mid-pipeline failure is just
"not yet summarized" (retryable, self-describing) rather than silent corruption.

## Structure

| Stage | Role | Store | Rule |
|---|---|---|---|
| **Bronze** | raw landing zone | whatever fits raw shape (time-series DB, object store, append log) | write-once, **never modified**, nothing derived yet |
| **Silver** | first derived layer | queryable summary store (relational, or a tagged time-series measurement) | one row/point per source unit, computed *from* bronze, not from the original fetch |
| **Gold** | aggregate layer (optional) | usually relational | computed from silver (+ bronze where raw detail is still needed), the analytics/rollup surface consumers actually query |

```
source(s) → BRONZE (land, untouched) → SILVER (derive, one unit at a time) → GOLD (aggregate)
              ↑ each stage: its own error boundary, self-healing from a backlog/watermark
```

**Self-healing, not transactional.** Because each stage is *derived from* the previous
one, recovery from a missed run doesn't replay the whole pipeline — each stage
independently finds its own backlog ("bronze rows with no silver yet," "silver rows newer
than gold's last aggregate") and catches up next cycle. This is what makes bronze/silver
splits worth the extra stage: the backlog query is the recovery mechanism, not a queue or
a saga.

## House adaptation

- **Bronze is sacred — never touched, never migrated in place.** If bronze needs a
  correction, that's a new bronze write or a documented one-off, not silver reaching back
  to mutate it.
- **Store choice per stage is a decision, not a given** — pick the store that fits what
  that stage actually holds (bronze: time-series/raw shape even for non-time-series
  sources, ADR-0009's "uniform bronze storage" reasoning: don't let a source's *current*
  data shape decide storage location, or every future source needs the same branching
  decision). Silver/gold: whatever the consumers actually query.
- **Watermark tracking, not a queue.** A nullable timestamp column, a small state file
  next to the script (`.foo-state`), or "rows where derived_at is null" are all fine — the
  point is a cheap, inspectable backlog query per stage, not a message broker.
- **Trigger mechanism defaults to sequential-in-process within one cron/job run** (bronze,
  then silver, then gold, each in its own try/except) unless there's a specific reason for
  separate schedules per stage — separate crons mean more moving parts and let stages
  drift apart in time for no benefit at typical personal/homelab data volumes.
- **Classification/derivation logic that has real branching (not just a reshape) earns
  its own tests**, split from the I/O glue — a disaggregation classifier, a TSS-strategy
  selector, anything with edge cases benefits from being independently testable without
  a live source or store.
- **Don't build a shared runner across pipelines just because the shape matches.** Name
  and document the *pattern* (this file) so each new instance starts from it instead of
  rediscovering it — but a shared *runtime/library* is only worth it once two pipelines in
  the *same substrate* (same language, same stores) show literal duplicated
  backlog/watermark code. Different substrates (Postgres+Influx vs. Influx-only vs.
  Postgres-only) make a forced shared abstraction leak one pipeline's assumptions into
  another's for no real reuse.

## Reference instantiation

Independently arrived at three times before being named here — worth checking this file
*before* the fourth time, not after:

- **`dynamic-training-calendar`/fit-processor** (ADR-0008, ADR-0009): sources (Garmin,
  Hevy) → InfluxDB bronze (uniform across sources, even non-time-series ones) → Postgres
  silver (`activities`, `activity_sets`) → Postgres gold (`training_load`,
  `activity_peaks`). Trigger: sequential in-process in the `dtc-ingest` cron.
- **`dynamic-training-calendar`/fit-processor** (ADR-0015): Home Assistant's shared-scale
  InfluxDB series as bronze (untouched, HA-owned) → a nearest-centroid classifier as
  silver, writing person-tagged points into the existing `health_metric` schema. Notable
  variant: silver here is a *disaggregation* (one bronze source → multiple identity-tagged
  outputs), not just a summary. **Live since 2026-08-13** — real backfill run against
  production (294 bronze points, 0 unclassified), daily incremental cron installed. Also a
  live example of "test the classifier, not just the I/O": a live dry-run caught a real bug
  (fixed-position CSV field parsing broke against InfluxDB's default column set) that 28
  passing unit tests against a narrower fixture shape hadn't caught.
- **`beaufort`/flightplan**: `bronze.time_entry`/`task_raw` → `tools/silver_etl`.

## Anti-patterns / when NOT

- **A one-off, human-invoked instrument to settle a specific debate** ("did the model get
  slower?") doesn't need bronze/silver rigor — see `stand-up-the-instrument` for that
  lighter shape (ingest → normalize → classify → summary, no durability/self-healing
  requirement). This pattern is what an instrument graduates into once it becomes a
  permanent, multi-consumer, ever-growing dataset other systems depend on.
- **Single-source, no real derivation** (the "summary" is just the raw row reshaped) —
  plain landing is enough, a silver stage that does nothing but copy is ceremony.
- **A durable source that's cheap to re-read in full** (e.g. probing a live registry that
  always reflects current truth, like HA's device registry) doesn't need a bronze landing
  step at all — a stateless full-refresh script is simpler and correct. Only reach for
  bronze/silver when the source is a stream you'd otherwise lose (activity fetches, sensor
  readings) or reprocessing it fully is expensive.
