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

Concrete targets are never named in this repo — each is a generic **release profile**
(`bin/release.sh --profile <handle>`) whose real specifics live in local, uncommitted
config. The three connectivity tiers:

```
  TIER 1 — LAN HUB (all LAN hosts)                 live query + shared git
    corpus on NAS + kb-mcp serving
        │  release --profile public ─[scrub: public]─►
        ▼
  PUBLIC GitHub mirror (base only, scrubbed)        anonymous clone + skills.sh
        │  clone / pull
        ▼
  TIER 2 — off-LAN, clone-capable target(s)         current-ish; contribute LATERALLY
        │  release --profile <handle> ─[scrub: <handle>]─►
        ▼
  TIER 3 — off-LAN, one-way sink(s)                 snapshot; idempotent install
           (field-kit self-extracting .ps1 bundle)
```

| Tier | Access | Freshness | Write-back |
|---|---|---|---|
| **1 — LAN** | kb-mcp live + shared git on NAS | always current | direct, all hosts |
| **2 — clone target** | clone public mirror + `skills.sh` install | pull on demand (freshness stamp) | local only → lateral package to teammates |
| **3 — one-way sink** | emailed `.ps1` release bundle | snapshot (version stamp) | effectively none |

Live MCP serving is LAN-only; off-LAN gets static (Tier 2) or bundled (Tier 3). Most of the
machinery already exists: kb-mcp (LAN), `skills.sh` (Tier 2, SKILL.md standard), and the
field-kit `make-field-bundle.sh` self-extracting bundle (Tier 3).

## Visibility partition (because it fans out to a public mirror)

```
base/        ← public-safe: your patterns + MIT/CC0 mixins (attribution). PUBLISHES.
overlays/
  <handle>/  ← private, per-profile layers — generic handles only, git-ignored,
             ←   never public. Composed onto base at release time for that profile.
```

`bin/release.sh --profile <handle>` composes `base` + that profile's *permitted* overlay
through that profile's **scrub list** (`~/.config/patterns/scrublist.<handle>`) — the
data-diode gate, one profile per boundary. **No real target name appears in this repo;**
the handle is generic and its real specifics live in local, uncommitted config.

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
| `bin/generate.py` | Corpus → per-tool artifacts (Cursor `.mdc`, Copilot `.instructions`/`.prompt`) + INDEX; SKILL.md-native tools use `skills.sh` |
| `bin/release.sh --profile <handle>` | Deliver to any target by generic profile: composes base + overlay, runs the profile's scrub gate, delivers via `sync` (git mirror) or `bundle` (self-extracting `.ps1`). Dry-run by default. |
| `bin/profiles.example.conf` | Template for a local profile conf (`~/.config/patterns/profiles/<handle>.conf`) |

## Status

Increment 1 — corpus + schema + seeds + first mixin reconcile + generator + directive.
See [SCHEMA.md](SCHEMA.md) and `base/mixins/superpowers/MANIFEST.md`.
