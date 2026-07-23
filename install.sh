#!/usr/bin/env bash
# install.sh — Harness v3 installer (POSIX)
# Runs on macOS, Linux, WSL, and git-bash on Windows.
# No external dependencies.

set -euo pipefail

# -------- Paths --------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/package"
HOME_DIR="${HOME:-$USERPROFILE}"
INSTALL_DIR="$HOME_DIR/.harness-v3"
BACKUP_DIR="$HOME_DIR/.harness-v3.bak.$(date +%Y%m%d-%H%M%S)"

# Tool config-file destinations
CLAUDE_FILE="$HOME_DIR/.claude/CLAUDE.md"
CODEX_FILE="$HOME_DIR/.codex/AGENTS.md"
ANTIGRAVITY_FILE="$HOME_DIR/.gemini/GEMINI.md"
OPENCODE_FILE="$HOME_DIR/.config/opencode/AGENTS.md"

BEGIN_MARKER="<!-- harness-v3:begin -->"
END_MARKER="<!-- harness-v3:end -->"
LEGACY_BEGIN="<!-- claude-harness:begin -->"
LEGACY_END="<!-- claude-harness:end -->"

# -------- Args --------
TOOLS_ARG=""
STEP_ARG=""
YES=false
while [ $# -gt 0 ]; do
  case "$1" in
    --tools) TOOLS_ARG="$2"; shift 2 ;;
    --step)  STEP_ARG="$2"; shift 2 ;;
    --yes|-y) YES=true; shift ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--tools claude,codex,antigravity,opencode] [--step 1|2|3|4] [--yes]

  --tools   Comma-separated list; default: auto-detect
  --step    Skip the diagnostic and set this step directly
  --yes     Skip confirmations (non-interactive)
EOF
      exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# -------- Helpers --------
say() { printf '%s\n' "$*"; }
prompt() { local p="$1"; printf '%s ' "$p" >&2; }
ask_yn() {
  local p="$1" default="${2:-n}" a
  if $YES; then a="$default"; else read -r a; fi
  [ -z "$a" ] && a="$default"
  [ "${a,,}" = "y" ] || [ "${a,,}" = "yes" ]
}

# Detect which tools have config dirs present.
detect_tools() {
  local found=()
  [ -d "$HOME_DIR/.claude" ]           && found+=("claude")
  [ -d "$HOME_DIR/.codex" ]            && found+=("codex")
  [ -d "$HOME_DIR/.gemini" ]           && found+=("antigravity")
  [ -d "$HOME_DIR/.config/opencode" ]  && found+=("opencode")
  printf '%s\n' "${found[@]:-}"
}

# Get the target file path for a tool key.
tool_file() {
  case "$1" in
    claude)      echo "$CLAUDE_FILE" ;;
    codex)       echo "$CODEX_FILE" ;;
    antigravity) echo "$ANTIGRAVITY_FILE" ;;
    opencode)    echo "$OPENCODE_FILE" ;;
    *) return 1 ;;
  esac
}

# Backup a file into the backup dir, preserving path structure.
backup_file() {
  local src="$1"
  [ -f "$src" ] || return 0
  local rel="${src#$HOME_DIR/}"
  local dst="$BACKUP_DIR/tool-files/$rel"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

# Remove a block delimited by two markers (idempotent).
remove_block() {
  local file="$1" begin="$2" end="$3"
  [ -f "$file" ] || return 0
  awk -v b="$begin" -v e="$end" '
    BEGIN { skip = 0 }
    index($0, b) { skip = 1; next }
    index($0, e) { skip = 0; next }
    !skip { print }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

# Insert or update the harness-v3 marker block. Content comes from HARNESS.md.
write_block() {
  local file="$1"
  mkdir -p "$(dirname "$file")"
  # remove any existing v3 block and any legacy v2 claude-harness block
  remove_block "$file" "$BEGIN_MARKER" "$END_MARKER"
  remove_block "$file" "$LEGACY_BEGIN" "$LEGACY_END"
  {
    [ -f "$file" ] && cat "$file"
    echo ""
    echo "$BEGIN_MARKER"
    echo "# Engineering Harness v3 (auto-installed - do not edit between markers)"
    echo "# Full harness at: $INSTALL_DIR"
    echo ""
    cat "$INSTALL_DIR/HARNESS.md"
    echo ""
    echo "$END_MARKER"
  } > "$file.tmp"
  mv "$file.tmp" "$file"
}

# -------- Step diagnostic (6 questions) --------
run_diagnostic() {
  # Prints the chosen step to stdout; all UI goes to stderr.
  # Answers stored globally in DIAG_ANSWERS for STEP.md.
  local q a i
  local -a scores=()
  {
    echo ""
    echo "=== Step diagnostic (6 questions, ~90 seconds) ==="
    echo "Choose the number that best matches your current practice."
    echo ""
  } >&2
  local questions=(
    "Concurrent agents in a normal session?|1) one at a time|2) 2-5 in parallel|3) ~10 with subagents|4) hundreds, mostly agent-initiated"
    "What do you review?|1) every response and edit|2) final diffs + evaluator reports|3) exceptions and drift signals|4) intent and outcomes, not diffs"
    "How is agent work verified before you see it?|1) I read the output|2) auto tests + lint + typecheck run first|3) separate verifier context grades it|4) full CI + verifier + auto-remediation"
    "Auto mode / permission prompts?|1) never, I approve each action|2) on for most, prompted for structural|3) always on with narrow gates|4) always on, cost caps govern"
    "Observability?|1) terminal output only|2) dashboard or analytics UI|3) OTel export + alerts|4) OTel + budget caps + exception dashboards"
    "Who initiates work?|1) only me|2) me + some scheduled routines|3) mostly me but the agent proactively starts related tasks|4) mostly the agent - I steer by intent"
  )
  for i in "${!questions[@]}"; do
    IFS='|' read -r q o1 o2 o3 o4 <<<"${questions[i]}"
    {
      echo "Q$((i+1)). $q"
      echo "  $o1"
      echo "  $o2"
      echo "  $o3"
      echo "  $o4"
    } >&2
    while :; do
      prompt "  answer [1-4]:"
      read -r a
      case "$a" in 1|2|3|4) scores+=("$a"); break ;; *) echo "  please enter 1, 2, 3, or 4" >&2 ;; esac
    done
    echo "" >&2
  done

  # Median rounded down (conservative).
  local sorted
  sorted=$(printf '%s\n' "${scores[@]}" | sort -n)
  local s3 s4
  s3=$(echo "$sorted" | sed -n '3p')
  s4=$(echo "$sorted" | sed -n '4p')
  # median of 6 values = average of 3rd and 4th, then floor
  local step=$(( (s3 + s4) / 2 ))

  {
    echo "=== Diagnostic complete ==="
    echo "Answers: ${scores[*]}"
    echo "Median (floored): $step"
    echo ""
  } >&2

  DIAG_ANSWERS="${scores[*]}"
  echo "$step"
}

# -------- Main --------
say "Harness v3 installer"
say "===================="

# Verify package/ exists next to this script.
[ -d "$PACKAGE_DIR" ] || { echo "package/ not found at $PACKAGE_DIR" >&2; exit 1; }
[ -f "$PACKAGE_DIR/HARNESS.md" ] || { echo "package/HARNESS.md missing" >&2; exit 1; }

# Detect tools.
say ""
say "Detecting installed tools..."
DETECTED=($(detect_tools))
if [ ${#DETECTED[@]} -eq 0 ]; then
  say "  (no supported tools detected)"
  say "  Supported: claude, codex, antigravity, opencode"
else
  say "  Found: ${DETECTED[*]}"
fi

# Choose which tools to install for.
if [ -n "$TOOLS_ARG" ]; then
  IFS=',' read -r -a SELECTED <<<"$TOOLS_ARG"
else
  if [ ${#DETECTED[@]} -eq 0 ]; then
    say ""
    say "No tools auto-detected. Enter comma-separated tool names to install for anyway,"
    say "or press Enter to abort: (choices: claude,codex,antigravity,opencode)"
    prompt "  tools:"
    if $YES; then echo ""; exit 0; fi
    read -r line
    [ -z "$line" ] && { say "aborting."; exit 0; }
    IFS=',' read -r -a SELECTED <<<"$line"
  else
    say ""
    prompt "Install for all detected tools? [Y/n]:"
    if ask_yn "" "y"; then
      SELECTED=("${DETECTED[@]}")
    else
      prompt "Enter comma-separated tool names:"
      read -r line
      IFS=',' read -r -a SELECTED <<<"$line"
    fi
  fi
fi

say ""
say "Selected: ${SELECTED[*]}"

# Diagnostic.
if [ -n "$STEP_ARG" ]; then
  STEP="$STEP_ARG"
  DIAG_ANSWERS="(skipped via --step)"
else
  STEP=$(run_diagnostic)
fi

# Confirm.
say "Will install to: $INSTALL_DIR"
say "Backup dir:      $BACKUP_DIR"
say "Step:            $STEP"
say "Tools:           ${SELECTED[*]}"
say ""
prompt "Proceed? [Y/n]:"
if ! ask_yn "" "y"; then say "aborted."; exit 0; fi

# Backup prior install.
mkdir -p "$BACKUP_DIR"
if [ -d "$INSTALL_DIR" ]; then
  say "Backing up existing $INSTALL_DIR..."
  mv "$INSTALL_DIR" "$BACKUP_DIR/harness-v3.previous"
fi

# Backup prior tool files. Record which files were created fresh so rollback
# can delete them (otherwise rollback would leave leftover files behind).
mkdir -p "$BACKUP_DIR"
CREATED_LIST="$BACKUP_DIR/created-fresh.txt"
: > "$CREATED_LIST"
say "Backing up tool config files..."
for tool in "${SELECTED[@]}"; do
  f=$(tool_file "$tool") || { echo "unknown tool: $tool" >&2; exit 1; }
  if [ -f "$f" ]; then
    backup_file "$f"
  else
    # File didn't exist before install; rollback should delete it.
    printf '%s\n' "$f" >> "$CREATED_LIST"
  fi
done

# Also back up the legacy Claude harness dir if present.
if [ -d "$HOME_DIR/.claude/harness" ]; then
  say "Backing up legacy ~/.claude/harness/ ..."
  cp -R "$HOME_DIR/.claude/harness" "$BACKUP_DIR/claude-harness.legacy"
fi

# Copy package.
say "Copying package to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -R "$PACKAGE_DIR/." "$INSTALL_DIR/"

# Copy scripts (set-step, uninstall).
mkdir -p "$INSTALL_DIR/scripts"
cp "$SCRIPT_DIR/scripts/set-step.sh" "$INSTALL_DIR/scripts/" 2>/dev/null || true
cp "$SCRIPT_DIR/scripts/set-step.ps1" "$INSTALL_DIR/scripts/" 2>/dev/null || true
cp "$SCRIPT_DIR/scripts/step-diagnostic.sh" "$INSTALL_DIR/scripts/" 2>/dev/null || true
cp "$SCRIPT_DIR/scripts/step-diagnostic.ps1" "$INSTALL_DIR/scripts/" 2>/dev/null || true
chmod +x "$INSTALL_DIR/scripts/"*.sh 2>/dev/null || true

# Write STEP.md.
cat > "$INSTALL_DIR/STEP.md" <<EOF
# STEP.md

**Current step:** $STEP

**Diagnostic answers:** $DIAG_ANSWERS

**Installed on:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

**Selected tools:** ${SELECTED[*]}

**See:** \`steps/step-${STEP}-*.md\` for the activation list at this step.

## Changing step

\`\`\`bash
~/.harness-v3/scripts/set-step.sh <1|2|3|4>
\`\`\`

Or re-run the diagnostic:

\`\`\`bash
~/.harness-v3/scripts/step-diagnostic.sh
\`\`\`
EOF

# Wire tools.
say "Wiring tools..."
for tool in "${SELECTED[@]}"; do
  f=$(tool_file "$tool") || continue
  say "  $tool -> $f"
  write_block "$f"
done

# Write rollback script into the backup dir.
cat > "$BACKUP_DIR/rollback.sh" <<'ROLLBACK_EOF'
#!/usr/bin/env bash
# Auto-generated rollback for harness-v3 install.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:-$USERPROFILE}"

echo "Rolling back harness-v3..."
echo "Backup dir: $DIR"

# Restore tool files that existed before install.
if [ -d "$DIR/tool-files" ]; then
  cd "$DIR/tool-files"
  find . -type f | while read -r rel; do
    dst="$HOME_DIR/${rel#./}"
    mkdir -p "$(dirname "$dst")"
    cp "$rel" "$dst"
    echo "  restored $dst"
  done
  cd - >/dev/null
fi

# Delete tool files that were created fresh by the install (no pre-install copy).
if [ -f "$DIR/created-fresh.txt" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    if [ -f "$f" ]; then
      rm "$f"
      echo "  removed $f (created by install)"
    fi
  done < "$DIR/created-fresh.txt"
fi

# Remove current install.
if [ -d "$HOME_DIR/.harness-v3" ]; then
  rm -rf "$HOME_DIR/.harness-v3"
  echo "  removed $HOME_DIR/.harness-v3"
fi

# Restore previous install if it existed.
if [ -d "$DIR/harness-v3.previous" ]; then
  cp -R "$DIR/harness-v3.previous" "$HOME_DIR/.harness-v3"
  echo "  restored $HOME_DIR/.harness-v3 (from previous install)"
fi

echo "Rollback complete."
ROLLBACK_EOF
chmod +x "$BACKUP_DIR/rollback.sh"

# Also mirror to PowerShell rollback.
cat > "$BACKUP_DIR/rollback.ps1" <<'ROLLBACK_PS_EOF'
# Auto-generated rollback for harness-v3 install.
$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$home_dir = $env:USERPROFILE
Write-Host "Rolling back harness-v3..."
Write-Host "Backup dir: $dir"

if (Test-Path "$dir\tool-files") {
    Get-ChildItem -Recurse -File "$dir\tool-files" | ForEach-Object {
        $rel = $_.FullName.Substring("$dir\tool-files\".Length)
        $dst = Join-Path $home_dir $rel
        $dstDir = Split-Path -Parent $dst
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
        Copy-Item $_.FullName $dst -Force
        Write-Host "  restored $dst"
    }
}

$createdList = Join-Path $dir "created-fresh.txt"
if (Test-Path $createdList) {
    Get-Content $createdList | Where-Object { $_ -ne '' } | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item -Force $_
            Write-Host "  removed $_ (created by install)"
        }
    }
}

$installDir = Join-Path $home_dir ".harness-v3"
if (Test-Path $installDir) {
    Remove-Item -Recurse -Force $installDir
    Write-Host "  removed $installDir"
}

$prev = Join-Path $dir "harness-v3.previous"
if (Test-Path $prev) {
    Copy-Item $prev $installDir -Recurse -Force
    Write-Host "  restored $installDir (from previous install)"
}

Write-Host "Rollback complete."
ROLLBACK_PS_EOF

# Summary.
say ""
say "=== Install complete ==="
say "  Harness:  $INSTALL_DIR"
say "  Step:     $STEP  (see $INSTALL_DIR/STEP.md)"
say "  Tools:    ${SELECTED[*]}"
say "  Backup:   $BACKUP_DIR"
say ""
say "Rollback anytime with:  $BACKUP_DIR/rollback.sh"
say ""
