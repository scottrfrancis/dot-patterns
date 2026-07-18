# Mixin: Superpowers — reconcile record

Vendored external source, reconciled against `base/` via the **data-diode-list-control**
pattern (base = white/authoritative, duplicate = black/suppress, overlap = gray/decide).

## Provenance

- **Source:** obra/superpowers — "A complete software development methodology for coding
  agents, built on composable skills." (Jesse Vincent / Prime Radiant)
- **Origin:** https://github.com/obra/superpowers
- **License:** MIT (vendor freely with attribution) — verified.
- **Format:** Agent-Skills `SKILL.md` (2-field frontmatter: `name`, `description`-as-trigger).
- **Distribution upstream:** `/plugin install superpowers@claude-plugins-official`, or
  `skills.sh` fan-out to Cursor/Codex/OpenCode/Droid/Copilot CLI.
- **Reconciled:** 2026-07-18. Commit pin: *unpinned* (pin on first verbatim vendor).

## Reconcile decision (13 upstream skills)

**ACCEPT (white → served)** — genuinely additive over `base` + model knowledge; these fill
your thinnest area (methodology orchestration):

| Skill | Why additive |
|---|---|
| `using-git-worktrees` | Parallel-branch isolation so concurrent agents don't collide — base has git-workflow but not worktree isolation. |
| `dispatching-parallel-agents` | Fan-out/gather orchestration of subagents — base has no parallel-agent discipline. |
| `verification-before-completion` | A "prove it works before you claim done" gate — sharper than base's testing guidance. |
| `writing-skills` | Meta: how to author a good skill/pattern entry — directly useful for growing THIS library. |

**SUPPRESS (black → recorded, not served)** — `base` already owns these; serving them
would duplicate:

| Skill | Suppressed because base has |
|---|---|
| `test-driven-development` | `testing` guideline + the global RED-GREEN-REFACTOR rule |
| `requesting-code-review` / `receiving-code-review` | `review-pr`, `arch-review`, `design-review` |
| `brainstorming` / `writing-plans` / `executing-plans` | spec-driven SDLC suite (discovery-init, interview-to-spec, constitution) |
| `finishing-a-development-branch` | `git-workflow` (branch+PR+squash discipline) |
| `subagent-driven-development` | overlaps `dispatching-parallel-agents` (accepted) + Droid subagents |
| `systematic-debugging` | partial overlap; **GRAY** — revisit: base has no dedicated debugging skill, may promote later |
| `using-superpowers` | tool-specific bootstrap, not a portable pattern |

## Notes

- The four accepted entries here capture the **delta** (what each adds over base) with
  attribution; the canonical full text is upstream (install via `/plugin install` or
  `skills.sh`). Verbatim vendoring (for the air-gapped one-way path) is a follow-up — pin the
  commit and copy the real `SKILL.md` bodies then.
- One gray remains: `systematic-debugging`. Left unpromoted pending a decision on whether
  base should own a debugging discipline.
