#!/usr/bin/env bash
# Claude Code Harness Installer
# Usage: curl -sSL https://raw.githubusercontent.com/watchowski/harness/main/install.sh | bash

set -euo pipefail

OWNER="watchowski"
REPO="harness"
BRANCH="main"
BASE="https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH"

# Colours
GRN='\033[0;32m'; YLW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info() { echo -e "${GRN}[harness]${NC} $1"; }
warn() { echo -e "${YLW}[harness]${NC} $1"; }
err()  { echo -e "${RED}[harness]${NC} $1" >&2; }

echo ""
echo "  Claude Code Harness"
echo "  github.com/$OWNER/$REPO"
echo ""

# Warn if not in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  warn "Not in a git repository. Proceeding anyway."
fi

# Prompt before overwriting user-edited files; return 0 = proceed, 1 = skip
confirm_overwrite() {
  local file="$1"
  if [ -f "$file" ]; then
    warn "Existing $file found."
    printf "  Overwrite? [y/N] "
    read -r reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
      warn "  Skipping $file"
      return 1
    fi
  fi
  return 0
}

# Download one file, creating parent dirs
fetch() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if curl -sSfL "$BASE/$src" -o "$dst" 2>/dev/null; then
    info "  ✓ $dst"
  else
    err "  ✗ Failed: $src"
    return 1
  fi
}

# Files that always overwrite (user does not edit these)
CONTENT=(
  "CLAUDE.md"
  ".harness/principles.md"
  ".harness/a11y/A11Y.md"
  ".harness/a11y/references/forms.md"
  ".harness/a11y/references/navigation.md"
  ".harness/a11y/references/modals.md"
  ".harness/a11y/references/contrast.md"
  ".harness/a11y/references/images.md"
  ".harness/a11y/REPORT.md"
  ".claude/hooks/pre-commit"
  ".claude/hooks/stop"
  "docs/harness/overview.md"
  "docs/harness/principles/01-hardening.md"
  "docs/harness/principles/02-context-hygiene.md"
  "docs/harness/principles/03-living-documentation.md"
  "docs/harness/principles/04-disposable-blueprint.md"
  "docs/harness/principles/05-institutional-memory.md"
  "docs/harness/principles/06-specialized-review.md"
  "docs/harness/principles/07-observability.md"
  "docs/harness/principles/08-strategic-human-gate.md"
  "docs/harness/principles/09-token-economy.md"
  "docs/harness/principles/10-toolkit.md"
)

# Files that prompt before overwrite (user may have edited these)
PROTECTED=(
  ".harness/a11y/EXCEPTIONS.md"
  ".claude/settings.json"
)

for f in "${CONTENT[@]}";    do fetch "$f" "$f"; done
for f in "${PROTECTED[@]}";  do confirm_overwrite "$f" && fetch "$f" "$f" || true; done

# Make hooks executable
chmod +x .claude/hooks/pre-commit .claude/hooks/stop
info "  ✓ hooks marked executable"

# Seed learnings file if absent
if [ ! -f "docs/harness/learnings.md" ]; then
  mkdir -p docs/harness
  cat > docs/harness/learnings.md << 'EOF'
# Institutional Learnings

Lessons codified from agent mistakes per Principle 05 — Institutional Memory.

---

<!-- Entries added here by the Stop hook after each session -->
EOF
  info "  ✓ docs/harness/learnings.md (created)"
fi

echo ""
info "Harness installed. Open Claude Code in this directory to activate."
echo ""
