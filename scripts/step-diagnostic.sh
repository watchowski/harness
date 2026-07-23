#!/usr/bin/env bash
# step-diagnostic.sh — re-run the 6-question step diagnostic and update STEP.md.
set -euo pipefail

HOME_DIR="${HOME:-$USERPROFILE}"
INSTALL_DIR="$HOME_DIR/.harness-v3"
STEP_FILE="$INSTALL_DIR/STEP.md"
[ -f "$STEP_FILE" ] || { echo "$STEP_FILE not found — run install.sh first" >&2; exit 1; }

prompt() { printf '%s ' "$1" >&2; }

echo ""
echo "=== Step diagnostic (6 questions, ~90 seconds) ==="
echo ""

questions=(
  "Concurrent agents in a normal session?|1) one at a time|2) 2-5 in parallel|3) ~10 with subagents|4) hundreds, mostly agent-initiated"
  "What do you review?|1) every response and edit|2) final diffs + evaluator reports|3) exceptions and drift signals|4) intent and outcomes, not diffs"
  "How is agent work verified before you see it?|1) I read the output|2) auto tests + lint + typecheck run first|3) separate verifier context grades it|4) full CI + verifier + auto-remediation"
  "Auto mode / permission prompts?|1) never, I approve each action|2) on for most, prompted for structural|3) always on with narrow gates|4) always on, cost caps govern"
  "Observability?|1) terminal output only|2) dashboard or analytics UI|3) OTel export + alerts|4) OTel + budget caps + exception dashboards"
  "Who initiates work?|1) only me|2) me + some scheduled routines|3) mostly me but the agent proactively starts related tasks|4) mostly the agent - I steer by intent"
)

scores=()
for i in "${!questions[@]}"; do
  IFS='|' read -r q o1 o2 o3 o4 <<<"${questions[i]}"
  echo "Q$((i+1)). $q"
  echo "  $o1"
  echo "  $o2"
  echo "  $o3"
  echo "  $o4"
  while :; do
    prompt "  answer [1-4]:"
    read -r a
    case "$a" in 1|2|3|4) scores+=("$a"); break ;; *) echo "  please enter 1, 2, 3, or 4" ;; esac
  done
  echo ""
done

sorted=$(printf '%s\n' "${scores[@]}" | sort -n)
s3=$(echo "$sorted" | sed -n '3p')
s4=$(echo "$sorted" | sed -n '4p')
step=$(( (s3 + s4) / 2 ))

echo "Answers: ${scores[*]}"
echo "Median (floored): $step"
echo ""
prompt "Accept step $step? [Y/n]:"
read -r accept
if [ -n "$accept" ] && [ "${accept,,}" != "y" ] && [ "${accept,,}" != "yes" ]; then
  prompt "Override to which step? [1-4]:"
  read -r step
  case "$step" in 1|2|3|4) ;; *) echo "invalid"; exit 2 ;; esac
fi

awk -v s="$step" -v a="${scores[*]}" '
  BEGIN { d1=0; d2=0 }
  /^\*\*Current step:\*\*/ && !d1 { print "**Current step:** " s; d1=1; next }
  /^\*\*Diagnostic answers:\*\*/ && !d2 { print "**Diagnostic answers:** " a; d2=1; next }
  { print }
' "$STEP_FILE" > "$STEP_FILE.tmp" && mv "$STEP_FILE.tmp" "$STEP_FILE"

echo "STEP.md updated. Current step: $step."
