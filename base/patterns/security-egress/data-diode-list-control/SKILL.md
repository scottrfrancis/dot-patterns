---
name: data-diode-list-control
description: >
  Use when guarding a one-way egress boundary — pushing to a public remote, emailing a
  bundle off a locked-down machine, publishing an artifact, shipping logs. Apply
  block/allow/pending (black/white/gray) lists so unrecognized identifiers surface for
  review BEFORE they leak, and known-bad ones are blocked outright.
id: data-diode-list-control
category: security-egress
invocation: model
aliases: [black-white-gray, scrublist, egress-control]
triggers: [egress, pre-push, redaction, allowlist, scrublist, one-way boundary, publish, air-gap]
source: base
license: null
origin-url: null
stance: null
status: active
related: [defense-in-depth]
visibility: public
---

# Data-Diode List Control (Black / White / Gray)

## Intent

A one-way egress boundary — a *data diode* — lets content out and cannot recall it: a
public push, an off-box email, an outbound webhook. The risk is a **known-bad or
*unrecognized* identifier riding out** in otherwise-fine content (a client name, host,
person, codename). A blacklist alone is brittle — it only catches what you already
thought of. The pattern adds a discovery tier so the blacklist grows *before* the leak.

## Structure

| List | Role | On match | Edited by |
|---|---|---|---|
| **Blacklist** | deny | **block** the egress (hard gate) | you |
| **Whitelist** | allow | **silence** — known-safe, ignore | you |
| **Graylist** | pending | **advise** — seen, undecided, **promotable** to black/white | tool proposes; you promote |

```
   content crossing the boundary → extract candidate identifiers
        in BLACK? → BLOCK      in WHITE? → SILENCE      in neither → GRAY → advise
                                                    promote ─► BLACK (scrub) or WHITE (safe)
```

## House adaptation

- **Detect broadly, block narrowly.** Fuzzy detection (proper nouns, CamelCase, domains,
  host/user strings) finds *candidates*; exact/regex blocking never false-positives (a
  bare common word as a blacklist entry gets the gate disabled out of frustration).
- **Grays are advisory, never blocking** — blocking on unknowns trains people to bypass
  the gate. Reserve hard failure for the blacklist (+ an opt-in `--strict` CI mode).
- **Record grays so they nag once**; promotion is one human action.
- **Advise before the point of no return, automatically** — a pre-push/pre-send hook,
  not a step to remember. The value is catching the *unremembered* leak.
- **Recall over precision for grays; precision over recall for the blacklist.**
- **The lists are secrets-adjacent** — the blacklist enumerates what you're hiding. Keep
  list files local/uncommitted; ship only placeholder `.example` templates.
- **Per-destination profiles** when one boundary differs from another (public vs. a
  same-employer channel vs. an air-gapped sink): parameterize the lists by hop.

## Reference instantiation

`dot-copilot` field kit: `bin/make-field-bundle.sh` scrub gate (blacklist, aborts the
build), `bin/entity-advisory.py` + graylist (`--promote TERM --to scrub|allow`), the
`pre-push` hook, and the `/scrub-check` agent pass. This very `dot-patterns` repo uses it
to reconcile mixins (base=white, dup=black, overlap=gray) and to gate the public publish.

## Anti-patterns / when NOT

- Reversible flows or a small fully-known sensitive set → a plain blacklist is enough;
  the graylist earns its keep when you *don't* yet know everything to block.
- Never a substitute for **not collecting** the sensitive thing in the first place —
  this is defense-in-depth, not the primary control.
