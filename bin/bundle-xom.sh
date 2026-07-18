#!/usr/bin/env bash
# bundle-xom.sh — package base/ + overlays/xom into the one-way XOM release.
#
# Reuses the field-kit self-extracting .ps1 mechanism (make-field-bundle.sh): stages the
# public corpus + the xom overlay, generates the per-tool artifacts, then hands off to the
# field-kit bundler which zips → SHA-256 → base64 → self-extracting .ps1, gated by the xom
# scrub profile. One-way delivery to the air-gapped box.
#
#   bundle-xom.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> generate corpus for XOM (base + overlays/xom)"
python3 "$ROOT/bin/generate.py" --visibility xom

echo "==> hand off to the field-kit self-extracting bundler"
echo "    Stage dist/xom + base/ + overlays/xom into a kit dir, then run:"
echo "      FIELD_KIT_SCRUBLIST=~/.config/patterns.scrublist.xom \\"
echo "        /Volumes/workspace/dot-copilot/bin/make-field-bundle.sh"
echo "    → emits a self-extracting .ps1 (see the self-extracting-release-over-narrow-channel"
echo "      pattern). Email as .txt; rename to .ps1 on XOM; run to install the patterns."
echo
echo "NOTE: increment-1 scaffold — the field-kit bundler currently targets the Copilot kit."
echo "Generalizing it to take an arbitrary staged payload dir is the next build."
