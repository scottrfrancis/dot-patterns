---
name: verification-before-completion
description: >
  Use before claiming any task done. Prove the change actually works by exercising it
  end-to-end and observing the result — never report "done" from "the code looks right" or
  "the tests I wrote pass".
id: verification-before-completion
category: workflow
invocation: model
source: mixin:superpowers
license: MIT
origin-url: https://github.com/obra/superpowers
status: active
visibility: public
related: []
---

# Verification Before Completion (mixin: Superpowers, MIT)

> Vendored delta. Canonical text upstream: https://github.com/obra/superpowers —
> install via `/plugin install superpowers@claude-plugins-official` or `skills.sh`.

## Delta over base (why this is here)

Base has strong test discipline (TDD) but not a crisp **"prove it before you claim done"**
gate. This is the gate: completion is a claim about *observed behavior*, not about code
appearance or a green test you also wrote. It catches the "confidently wrong" report.

## Core practice

- Before saying done, **drive the actual flow** the change affects and observe the output —
  not just typecheck/lint, not just unit tests.
- State what you verified and *how* ("ran X, saw Y"), so the claim is auditable.
- If you can't verify it, say so — "implemented but unverified" beats a false "done".
- Failing/ skipped steps are reported with the evidence, never smoothed over.

## When NOT

Pure docs/comment changes with no runtime surface to exercise — there's nothing to observe.
Everything with behavior gets verified.
