#!/usr/bin/env bash
# Copy the Depfloy skill into the plugin from its one source:
# depfloy/depfloy (depfloy-app) resources/skills/depfloy, which the MCP server
# also publishes through the Skills extension (DP-500). Edit the skill there,
# never here — a change made only in this copy is overwritten by the next sync.
#
#   scripts/sync-skill.sh                     from depfloy/depfloy@master (needs gh)
#   scripts/sync-skill.sh --ref <branch|sha>  from another ref
#   scripts/sync-skill.sh --from <dir>        from a local depfloy-app checkout
#   add --check to compare only: exit 1 if the plugin's copy differs
set -euo pipefail

REPO=depfloy/depfloy
SRC_PATH=resources/skills/depfloy
DEST="$(cd "$(dirname "$0")/.." && pwd)/plugins/depfloy/skills/depfloy"
REF=master FROM= CHECK=0

while [ $# -gt 0 ]; do
  case "$1" in
    --ref) REF=$2; shift 2 ;;
    --from) FROM=$2; shift 2 ;;
    --check) CHECK=1; shift ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

if [ -n "$FROM" ]; then
  cp -R "$FROM/$SRC_PATH/." "$STAGE/"
else
  gh api "repos/$REPO/git/trees/$REF?recursive=1" \
    --jq ".tree[] | select(.type == \"blob\" and (.path | startswith(\"$SRC_PATH/\"))) | .path" |
  while read -r path; do
    rel=${path#"$SRC_PATH/"}
    mkdir -p "$STAGE/$(dirname "$rel")"
    gh api -H 'Accept: application/vnd.github.raw' "repos/$REPO/contents/$path?ref=$REF" > "$STAGE/$rel"
  done
fi

[ -f "$STAGE/SKILL.md" ] || { echo "no SKILL.md at $SRC_PATH (${FROM:-$REPO@$REF})" >&2; exit 1; }

if [ "$CHECK" = 1 ]; then
  if diff -r "$STAGE" "$DEST" >/dev/null; then echo "skill in sync with ${FROM:-$REPO@$REF}"; exit 0; fi
  diff -ru "$DEST" "$STAGE" || true
  echo "plugin skill differs from ${FROM:-$REPO@$REF}; run scripts/sync-skill.sh" >&2
  exit 1
fi

rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$STAGE/." "$DEST/"
echo "copied skill from ${FROM:-$REPO@$REF}"
