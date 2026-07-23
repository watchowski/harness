#!/usr/bin/env bash
# set-step.sh — change the installed harness step tier.
set -euo pipefail

HOME_DIR="${HOME:-$USERPROFILE}"
INSTALL_DIR="$HOME_DIR/.harness-v3"
STEP_FILE="$INSTALL_DIR/STEP.md"

if [ $# -ne 1 ]; then
  echo "usage: $0 <1|2|3|4>" >&2
  exit 2
fi
case "$1" in 1|2|3|4) ;; *) echo "step must be 1, 2, 3, or 4" >&2; exit 2 ;; esac
[ -f "$STEP_FILE" ] || { echo "$STEP_FILE not found — run install.sh first" >&2; exit 1; }

# Rewrite the current step line.
awk -v s="$1" '
  BEGIN { done=0 }
  /^\*\*Current step:\*\*/ && !done { print "**Current step:** " s; done=1; next }
  { print }
' "$STEP_FILE" > "$STEP_FILE.tmp" && mv "$STEP_FILE.tmp" "$STEP_FILE"

echo "Step set to $1. See $STEP_FILE."
