# dot-patterns

A curated, layered library of software **design patterns and practices** — the
Gang-of-Four canon (indexed, with house stances), personal patterns distilled from
real work, and vetted external mixins — served to every AI coding agent so they
*consult and reuse* known patterns instead of reinventing them.

## Why this exists

Guidelines scattered across tool repos are a proto-library, but agents don't reliably
*use* them at design time, and the same practice gets re-derived (or duplicated from an
external source) again and again. This repo is the single authoritative corpus, plus the
machinery to (a) keep external libraries as **non-duplicating mixins** and (b) serve the
distilled knowledge to agents in every environment.

## Layering — base + mixins, deduped (the black/white/gray pattern, applied to curation)

```
  base/patterns/     ← YOUR authored patterns + GoF index (authoritative, highest precedence)
  base/mixins/<src>/ ← vetted external libraries (Superpowers, …), VENDORED + reconciled
        │
   reconcile (see the data-diode-list-control pattern):
     base already covers it → SUPPRESS   [black]   (recorded, not served)
     genuinely additive      → ACCEPT     [white]
     partial overlap         → GRAY → you merge or keep-the-delta
```

Mixins are **vendored, namespaced, provenance-tagged, and reconciled** — never
blind-copied. Only the *delta over what your base (and the model) already know* is served.
Base always wins on conflict.

## Entry format — SKILL.md (the Agent-Skills standard) + extended frontmatter

One pattern = one directory with a `SKILL.md`. Frontmatter keeps the two portable fields
(`name`, `description`-as-trigger — what `skills.sh` and every skills-aware tool reads) and
adds optional curation fields this repo's tooling uses. See [SCHEMA.md](SCHEMA.md).

## Serving across three environments (maximize LAN; degrade gracefully)

This library is *methodology* served under the same doctrine as the ops-knowledge state:
**dynamic + archival, local-first, WAN-tolerant.** Connectivity decreases down a diode
chain; a scrub gate sits at every outbound hop.

```
  LAN HUB (Studio/Hasami/dev/dev-ai/razer14)      live query + shared git
    corpus on NAS + kb-mcp serving (mini)
        │  publish ─[scrub: public profile]─►
        ▼
  PUBLIC GitHub mirror (base only, scrubbed)       anonymous clone + skills.sh
        │  clone/pull
        ▼
  EY laptop (read-mostly; local overlay)           current-ish; contribute LATERALLY
        │  release package ─[scrub: xom profile]─►
        ▼
  XOM laptop (one-way sink; field-kit .ps1 bundle) snapshot; idempotent install
```

| Env | Access | Freshness | Write-back |
|---|---|---|---|
| **LAN** | kb-mcp live + shared git on NAS | always current | direct, all hosts |
| **EY** | clone public mirror + `skills.sh` install | pull on demand (freshness stamp) | local only → lateral package to teammates |
| **XOM** | emailed `.ps1` release bundle | snapshot (version stamp) | effectively none |

Live MCP serving is LAN-only; off-LAN gets static (EY) or bundled (XOM). Most of the
machinery already exists: kb-mcp (LAN), `skills.sh` (EY, SKILL.md standard), and the
field-kit `make-field-bundle.sh` self-extracting bundle (XOM).

## Visibility partition (because it fans out to a public mirror)

```
base/        ← public-safe: your patterns + MIT/CC0 mixins (attribution). PUBLISHES.
overlays/
  home/      ← LAN-only (homelab/ops-adjacent)
  ey/        ← EY engagement patterns — never public; shareable to EY teammates only
  xom/       ← XOM-specific — travels only in the XOM bundle
```

Publish/bundle steps compose `base` + the destination's *permitted* overlay through that
destination's **scrub profile** (`scrublist.public`, `.ey`, `.xom`) — the data-diode
gate, one profile per boundary.

## Making agents actually use it (three reinforcing layers)

1. **Directive** — one always-on line in each tool's base rules: *consult the library
   before designing or coining a mechanism; name the pattern you apply.* See
   [`bin/directive-snippet.md`](bin/directive-snippet.md).
2. **Retrieval** — `description`-as-trigger drives model auto-invocation; kb-mcp `search`
   for live query on the LAN.
3. **Enforcement** — `arch-review`/`design-review` ask "was a known pattern reused? any
   reinvention? any new pattern worth capturing?"

## Tooling

| Script | Does |
|---|---|
| `bin/reconcile.py` | Compare a mixin source against the base index → accept/suppress/gray (black/white/gray) |
| `bin/generate.py` | Corpus → per-tool artifacts (Cursor `.mdc`, Copilot `.instructions`/`.prompt`); SKILL.md-native tools use `skills.sh` |
| `bin/publish.sh` | `base` → public mirror through `scrublist.public` (dry-run first) |
| `bin/bundle-xom.sh` | `base + overlays/xom` → self-extracting `.ps1` (reuses field-kit) |

## Status

Increment 1 — corpus + schema + seeds + first mixin reconcile + generator + directive.
See [SCHEMA.md](SCHEMA.md) and `base/mixins/superpowers/MANIFEST.md`.
