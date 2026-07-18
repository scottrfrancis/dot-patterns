---
name: dispatching-parallel-agents
description: >
  Use when a task decomposes into independent sub-tasks that can run at once — fan out one
  subagent per sub-task, gather and reconcile their results, instead of doing them serially.
id: dispatching-parallel-agents
category: agent-orchestration
invocation: user
source: mixin:superpowers
license: MIT
origin-url: https://github.com/obra/superpowers
status: active
visibility: public
related: [using-git-worktrees]
---

# Dispatching Parallel Agents (mixin: Superpowers, MIT)

> Vendored delta. Canonical text upstream: https://github.com/obra/superpowers —
> install via `/plugin install superpowers@claude-plugins-official` or `skills.sh`.

## Delta over base (why this is here)

Base has no explicit parallel-agent orchestration discipline. This names the pattern:
**decompose → fan out one agent per independent unit → gather → reconcile.** Turns a serial
slog (review N dimensions, migrate N files, research N angles) into wall-clock ≈ slowest
single unit.

## Core practice

- Decompose into units with **no cross-dependencies** (independent by construction).
- One agent per unit, each with a tight scope and a structured return.
- **Gather then reconcile** — dedup/merge across results; a barrier only when a later stage
  genuinely needs all prior results together (otherwise pipeline).
- Isolate file-mutating agents with worktrees (`using-git-worktrees`).
- Verify each result before trusting it (`verification-before-completion`).

## When NOT

Inherently sequential work, or units that share mutable state — the coordination overhead
and merge conflicts outweigh the parallelism. Fan out breadth, not a dependency chain.
