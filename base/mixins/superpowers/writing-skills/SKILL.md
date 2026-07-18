---
name: writing-skills
description: >
  Use when authoring a new skill/pattern entry for this library. A good entry is a
  trigger-first, decision-grade discipline — write the description as an activation trigger,
  keep the body about when/why/how-house, not a tutorial.
id: writing-skills
category: workflow
invocation: user
source: mixin:superpowers
license: MIT
origin-url: https://github.com/obra/superpowers
status: active
visibility: public
related: [gof-index]
---

# Writing Skills (mixin: Superpowers, MIT)

> Vendored delta. Canonical text upstream: https://github.com/obra/superpowers —
> install via `/plugin install superpowers@claude-plugins-official` or `skills.sh`.

## Delta over base (why this is here)

This library needs a meta-discipline for authoring entries. Superpowers' `writing-skills`
is exactly that, adapted here to this repo's [SCHEMA.md](../../../../SCHEMA.md).

## Core practice

- **`description` is the activation trigger** — imperative, keyword-rich ("Use when… / You
  MUST use this before…"). It's what drives model auto-invocation and `search`. Spend the
  most care here.
- **One skill = one concern.** If it needs "and", it's two skills.
- **Body = when / why / house-take / reference / when-not** — not a re-teaching of what the
  model already knows. Capture the *delta*: your stance, your adaptation.
- **Don't duplicate.** Before adding, reconcile against the base index (data-diode
  reconcile) — suppress what base already covers, keep only the delta.
- Set the extended frontmatter (`category`, `invocation`, `visibility`, and for mixins
  `source`/`license`/`origin-url`).

## When NOT

A one-off note — that's a comment or a doc, not a library entry. Entries are reusable
disciplines an agent should pull across many tasks.
