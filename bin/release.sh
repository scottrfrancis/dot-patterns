#!/usr/bin/env bash
# release.sh — deliver the pattern corpus to a target, selected by a generic PROFILE.
#
# The repo NEVER names a real target. A profile is a generic handle; its real specifics
# (which overlay, which scrub list, where it goes, how it's delivered) live only in a
# LOCAL, uncommitted config: ~/.config/patterns/profiles/<name>.conf  (see
# bin/profiles.example.conf). This is the data-diode principle applied to the tooling
# itself — identifiers stay out of anything that could be published.
#
#   release.sh --profile public              # dry-run the built-in public profile
#   release.sh --profile <name>              # dry-run a local profile
#   release.sh --profile <name> --go         # actually deliver
#
# A profile conf defines:
#   OVERLAY=<name>          # overlay dir to include (= visibility); empty = base only
#   SCRUBLIST=<path>        # black/white/gray list for THIS boundary
#   METHOD=sync|bundle      # git-mirror sync, or self-extracting one-way bundle
#   DEST=<path-or-remote>   # sync target (METHOD=sync)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADVISORY="${PATTERNS_ADVISORY:-/Volumes/workspace/dot-copilot/bin/entity-advisory.py}"
PROFILE_DIR="${PATTERNS_PROFILE_DIR:-$HOME/.config/patterns/profiles}"

PROFILE=""; GO=0
while [ $# -gt 0 ]; do case "$1" in
  --profile) PROFILE="$2"; shift 2 ;;
  --go) GO=1; shift ;;
  --dry-run) GO=0; shift ;;
  *) echo "unknown arg: $1" >&2; exit 2 ;;
esac; done
[ -n "$PROFILE" ] || { echo "usage: release.sh --profile <name> [--go]" >&2; exit 2; }

# ── resolve the profile (built-in 'public', else a local conf) ──
OVERLAY=""; METHOD="sync"; DEST=""
SCRUBLIST="$HOME/.config/patterns/scrublist.$PROFILE"
if [ "$PROFILE" = "public" ]; then
  : # base only, sync to the public mirror; DEST supplied by conf or left unset for dry-run
fi
CONF="$PROFILE_DIR/$PROFILE.conf"
if [ -f "$CONF" ]; then
  # shellcheck disable=SC1090
  . "$CONF"
elif [ "$PROFILE" != "public" ]; then
  echo "release: no profile conf at $CONF (see bin/profiles.example.conf)" >&2
  exit 2
fi

VIS="${OVERLAY:-public}"
echo "==> profile '$PROFILE'  (overlay=${OVERLAY:-<none>}, method=$METHOD)"

echo "==> generate corpus (visibility=$VIS)"
python3 "$ROOT/bin/generate.py" --visibility "$VIS" >/dev/null

echo "==> stage"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/patterns-rel.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
cp -R "$ROOT/base" "$STAGE/base"
cp "$ROOT/README.md" "$ROOT/SCHEMA.md" "$ROOT/VERSION" "$STAGE/" 2>/dev/null || true
[ -n "$OVERLAY" ] && [ -d "$ROOT/overlays/$OVERLAY" ] && cp -R "$ROOT/overlays/$OVERLAY" "$STAGE/overlay"
cp -R "$ROOT/dist/$VIS" "$STAGE/generated" 2>/dev/null || true
# hard guard: no OTHER overlay may ride along
if find "$STAGE" -path '*/overlays/*' | grep -q .; then
  echo "release: ABORT — stray overlay content staged" >&2; exit 3; fi

echo "==> scrub gate (profile list: $SCRUBLIST)"
if [ -f "$SCRUBLIST" ]; then
  HITS=0
  while IFS= read -r pat; do case "$pat" in ""|"#"*) continue ;; esac
    if grep -riIl -- "$pat" "$STAGE" >/dev/null 2>&1; then
      echo "SCRUB HIT: '$pat'"; grep -riIl -- "$pat" "$STAGE"; HITS=1; fi
  done < "$SCRUBLIST"
  [ "$HITS" = 0 ] || { echo "release: ABORT — scrub the hits above" >&2; exit 4; }
  [ -f "$ADVISORY" ] && FIELD_KIT_SCRUBLIST="$SCRUBLIST" \
    python3 "$ADVISORY" --files $(find "$STAGE" -name '*.md') || true
  echo "    scrub gate clean"
else
  echo "    WARNING: no scrublist at $SCRUBLIST — gate SKIPPED (create it before --go)" >&2
  [ "$GO" = 1 ] && { echo "release: refusing --go with no scrublist" >&2; exit 5; }
fi

if [ "$GO" = 0 ]; then
  echo "==> dry run — nothing delivered. Re-run with --go."
  exit 0
fi

case "$METHOD" in
  sync)
    [ -n "$DEST" ] || { echo "release: METHOD=sync needs DEST in the profile conf" >&2; exit 2; }
    echo "==> sync base/ → $DEST"
    rsync -a --delete "$ROOT/base/" "$DEST/base/"
    cp "$ROOT/README.md" "$ROOT/SCHEMA.md" "$DEST/" 2>/dev/null || true
    echo "    synced. Commit + push the mirror from $DEST." ;;
  bundle)
    echo "==> self-extracting one-way bundle (field-kit self-extractor)"
    echo "    staged payload: $STAGE"
    echo "    FIELD_KIT_SCRUBLIST=$SCRUBLIST /Volumes/workspace/dot-copilot/bin/make-field-bundle.sh"
    echo "    → .ps1 (see the self-extracting-release-over-narrow-channel pattern)."
    echo "    NOTE: increment-1 — generalizing the bundler to an arbitrary payload dir is the next build." ;;
  *) echo "release: unknown METHOD '$METHOD'" >&2; exit 2 ;;
esac
