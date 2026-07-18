#!/usr/bin/env bash
# publish.sh — LAN → public GitHub mirror, through the data-diode scrub gate.
#
# Publishes ONLY base/ (visibility:public) — overlays never leave. Runs the identity
# scrub (reusing dot-copilot's entity-advisory + scrublist) against the staged public
# tree; aborts on any blacklist hit; reports new grays. Advisory dry-run by default.
#
#   publish.sh --dry-run                 # scan + report, write nothing (default)
#   publish.sh --to <path-or-remote>     # sync base/ to the public mirror checkout
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADVISORY="${ADVISORY:-/Volumes/workspace/dot-copilot/bin/entity-advisory.py}"
PROFILE="${SCRUB_PROFILE:-$HOME/.config/patterns.scrublist.public}"
DRY=1; TARGET=""
while [ $# -gt 0 ]; do case "$1" in
  --to) TARGET="$2"; DRY=0; shift 2 ;;
  --dry-run) DRY=1; shift ;;
  *) echo "unknown arg: $1" >&2; exit 2 ;;
esac; done

echo "==> stage public tree (base/ only; overlays excluded)"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/patterns-pub.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
cp -R "$ROOT/base" "$STAGE/base"
cp "$ROOT/README.md" "$ROOT/SCHEMA.md" "$STAGE/" 2>/dev/null || true
# hard guard: no overlay content may have crept in
if find "$STAGE" -path '*/overlays/*' | grep -q .; then
  echo "publish: ABORT — overlay content in public stage" >&2; exit 3
fi

echo "==> identity scrub gate (public profile)"
if [ -f "$PROFILE" ] && [ -f "$ADVISORY" ]; then
  # blacklist block: reuse the field-kit scrub gate semantics via a grep pass
  HITS=0
  while IFS= read -r pat; do case "$pat" in ""|"#"*) continue ;; esac
    if grep -riIl -- "$pat" "$STAGE" >/dev/null 2>&1; then
      echo "SCRUB HIT: '$pat'"; grep -riIl -- "$pat" "$STAGE"; HITS=1; fi
  done < "$PROFILE"
  [ "$HITS" = 0 ] || { echo "publish: ABORT — scrub the hits above" >&2; exit 4; }
  # graylist advisory over the staged public tree
  FIELD_KIT_SCRUBLIST="$PROFILE" python3 "$ADVISORY" \
    --files $(find "$STAGE" -name '*.md') || true
  echo "    scrub gate clean (public profile)"
else
  echo "    WARNING: no public scrublist ($PROFILE) or advisory — gate SKIPPED" >&2
fi

if [ "$DRY" = 1 ]; then
  echo "==> dry run — nothing published. Re-run with --to <public-mirror-checkout>."
  exit 0
fi

echo "==> sync base/ → $TARGET"
rsync -a --delete "$ROOT/base/" "$TARGET/base/"
cp "$ROOT/README.md" "$ROOT/SCHEMA.md" "$TARGET/" 2>/dev/null || true
echo "    synced. Commit + push the mirror from $TARGET (skills.sh consumers pull it)."
