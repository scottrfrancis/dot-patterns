# Pattern entry schema

One pattern = one directory containing `SKILL.md`. The frontmatter is the
[Agent-Skills standard](https://github.com/obra/superpowers) two fields **plus**
optional curation fields. Standard-aware tools (`skills.sh`, Claude Code, Codex, …)
read `name` + `description`; this repo's tooling additionally reads the extended fields.

```yaml
---
# ── standard (required; what every skills-aware tool reads) ──
name: data-diode-list-control            # kebab-case, unique = the directory name
description: >                            # DOUBLES AS THE ACTIVATION TRIGGER — imperative,
  Use when guarding a one-way egress boundary (pre-push scrub, redaction,             # keyword-rich.
  publishing) — apply block/allow/pending lists so unknowns surface before they leak.

# ── extended (optional; this repo's curation layer) ──
id: data-diode-list-control              # stable id (= name; kept explicit for renames)
category: security-egress                # security-egress | data-flow | agent-orchestration |
                                         #   llm-integration | workflow | gof-creational |
                                         #   gof-structural | gof-behavioral | ops
invocation: model                        # model (auto-loaded discipline) | user (you trigger it)
aliases: [black-white-gray, scrublist]
triggers: [egress, pre-push, redaction, allowlist, one-way boundary]
source: base                             # base | mixin:superpowers | mixin:mattpocock | ...
license: null                            # mixin entries carry their license + origin-url
origin-url: null                         # provenance for vendored mixins (attribution)
stance: null                             # GoF entries: favored | avoided | adapted (+ why)
status: active                           # active | experimental | deprecated
related: [defense-in-depth]              # ids of related patterns
supersedes: null
superseded-by: null
visibility: public                       # public | home | ey | xom  (drives publish/bundle)
---

<markdown body>
```

## Body structure

Keep it a decision-grade pattern doc, not a tutorial:

1. **Intent** — one paragraph: the problem and the forces.
2. **Structure** — the participants / mechanism (a diagram if it helps).
3. **House adaptation** — *your* specific take (this is the value the model doesn't have).
4. **Reference instantiation** — where it's used in your work (link out).
5. **Anti-patterns / when NOT** — where it's the wrong tool.

## Conventions

- **`description` is the retrieval surface.** Write it as a trigger: "Use when… / You
  MUST use this before…". Keyword-rich so model-invocation and `search` both hit it.
- **`invocation: user` vs `model`** (from mattpocock/skills): user-invoked orchestration
  commands you trigger, vs model-invoked disciplines the agent auto-loads. Maps onto the
  commands-vs-instructions split in the tool repos.
- **Don't re-document what the model knows.** GoF patterns live as a single indexed file
  (`gof/INDEX.md`) — name + intent + *your stance* — not 23 tutorials. Personal patterns
  and mixin deltas get full `SKILL.md` entries.
- **`visibility`** gates fan-out: `public` publishes to the mirror; `home`/`ey`/`xom` stay
  in their overlay and travel only to that environment.
- **Mixin entries** must set `source`, `license`, `origin-url`. Reconcile before adding
  (see any `mixins/<src>/MANIFEST.md`).
