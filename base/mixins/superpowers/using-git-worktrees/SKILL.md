---
name: using-git-worktrees
description: >
  Use when several agents (or several parallel tasks) need to work in the same repo at
  once without stepping on each other's working tree — run each in its own git worktree
  on its own branch, then reconcile.
id: using-git-worktrees
category: agent-orchestration
invocation: model
source: mixin:superpowers
license: MIT
origin-url: https://github.com/obra/superpowers
status: active
visibility: public
related: [dispatching-parallel-agents]
---

# Using Git Worktrees (mixin: Superpowers, MIT)

> Vendored delta. Canonical text upstream: https://github.com/obra/superpowers —
> install via `/plugin install superpowers@claude-plugins-official` or `skills.sh`.

## Delta over base (why this is here)

Your `git-workflow` guideline covers branch+PR discipline but not **concurrent isolation**.
When you dispatch parallel agents against one repo, they collide in a shared working tree.
`git worktree add` gives each task its own checkout on its own branch — isolated files,
shared history — so N agents run truly in parallel and merge back cleanly.

## Core practice

- One worktree per parallel task: `git worktree add ../wt-<slug> -b <type>/<slug> origin/main`.
- Each agent works only inside its worktree; no shared uncommitted state.
- Reconcile via normal PRs (your `git-workflow`); `git worktree remove` when merged.
- Auto-clean worktrees that end up unchanged.

## When NOT

Single-threaded work in one repo — a plain feature branch is simpler. Worktrees earn their
setup cost only when you actually run things in parallel.
