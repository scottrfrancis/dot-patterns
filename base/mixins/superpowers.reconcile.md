---
submodule: superpowers
origin: https://github.com/obra/superpowers
license: MIT
pinned: d884ae0
accept: [using-git-worktrees, dispatching-parallel-agents, verification-before-completion, writing-skills]
---

# Mixin reconcile: Superpowers

Vendored as a **git submodule** (`base/mixins/superpowers/` → obra/superpowers @ d884ae0,
MIT, LICENSE in the submodule). No content is copied/forked; the generator materializes
only the ACCEPTED skills at build time. Reconciled via the data-diode pattern
(base = white/authoritative, dup = black/suppress, overlap = gray).

## ACCEPT (white → generated into the corpus) — additive over base + model knowledge

| Skill | Why additive |
|---|---|
| `using-git-worktrees` | Concurrent-agent isolation — base git-workflow lacks worktree isolation. |
| `dispatching-parallel-agents` | Fan-out/gather orchestration — base has no parallel-agent discipline. |
| `verification-before-completion` | "Prove it before you claim done" gate — sharper than base testing. |
| `writing-skills` | Meta: authoring good library entries. |

## SUPPRESS (black → NOT generated) — base already owns these

`test-driven-development` (base testing + global RED-GREEN rule) ·
`requesting-code-review`/`receiving-code-review` (review-pr/arch-review/design-review) ·
`brainstorming`/`writing-plans`/`executing-plans` (spec-driven SDLC suite) ·
`finishing-a-development-branch` (git-workflow) ·
`subagent-driven-development` (overlaps accepted dispatching-parallel-agents) ·
`using-superpowers` (tool bootstrap, not a portable pattern).

## GRAY (pending) — `systematic-debugging`: base has no debugging discipline; promote later.

## Update

`git submodule update --remote base/mixins/superpowers`, re-verify the accept list still
resolves, bump `pinned:`.
