---
name: self-extracting-release-over-narrow-channel
description: >
  Use when you must deliver code/config to a locked-down or near-air-gapped machine whose
  only inbound channel is restrictive (email attachments, text paste, no git, no installers,
  no unsigned binaries). Package a self-verifying, self-extracting script that survives the
  channel and reconstructs the payload locally.
id: self-extracting-release-over-narrow-channel
category: data-flow
invocation: user
aliases: [ps1-self-extractor, base64-release, air-gap-delivery]
triggers: [air-gap, locked-down, no git push, email only, one-way, release package, WDAC, managed device]
source: base
status: active
related: [data-diode-list-control, portable-context-lift]
visibility: public
---

# Self-Extracting Release Over a Narrow Channel

## Intent

A one-way, format-restricted inbound channel (corporate email that strips zips but passes
`.txt`; a machine with no git, no admin, no unsigned executables) still needs to receive
your tooling. Package it as **one text-safe, self-verifying, self-extracting artifact**
that the channel will pass and the target can run with only built-in tools.

## Structure

1. **Bundle** the payload (zip).
2. **Hash it** (SHA-256) and record the hash *inside* the delivered artifact.
3. **Encode** to text (base64) so it survives text-only channels; rename to the passing
   extension (`.txt` → the recipient renames to `.ps1`/`.sh`).
4. **Embed** the encoded payload in a **self-extractor script** using only the target's
   built-in runtime (PowerShell `FromBase64String`/`Expand-Archive`; or `base64 -d`).
5. On run: **decode → verify the embedded hash → extract to the current dir → print next
   steps.** Verification is non-negotiable — a mangled paste must fail loudly, not
   silently install corruption.
6. **Round-trip test on the build side**: reassemble from the emitted artifact, hash-match
   the original, extraction self-test — before it ships.

## House adaptation

- **The bootstrap/reassembly instructions ride *outside* the payload** (email body), since
  they can't live inside the archive they reconstruct.
- **Idempotent install** on the target (re-run replaces kit files, preserves local
  state/ledger) — updates arrive as occasional re-sends; make re-running safe.
- **Version-stamp** the artifact; the target should be able to say "N versions behind"
  because updates are hard and staleness is the default.
- **Pair with the data-diode gate** on the build side — nothing identifying rides out.
- Only the target's **built-in** runtime; assume no package manager, no admin, no signing.

## Reference instantiation

`dot-copilot/bin/make-field-bundle.sh` — zip → SHA-256 manifest → base64 → self-extracting
`.ps1` (Windows PowerShell 5.1 built-ins), scrub-gated, round-trip verified. Emailed as
`.txt`, renamed to `.ps1`, run once on the target.

## Anti-patterns / when NOT

- If the target can `git clone` or run a normal installer, do that — this is only for the
  genuinely narrow/one-way channel.
- Don't hand-roll crypto or "encryption" here; this is *integrity* (hash) and *transport
  encoding* (base64), not confidentiality. Confidentiality is a separate control.
