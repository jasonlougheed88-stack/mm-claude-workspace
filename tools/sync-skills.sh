#!/bin/bash
# sync-skills.sh — Sync skills between build folder (source of truth) and ~/.claude/skills/
#
# Usage:
#   ./tools/sync-skills.sh deploy   — Copy build/skills/ → ~/.claude/skills/ (apply updates)
#   ./tools/sync-skills.sh backup   — Copy ~/.claude/skills/ → build/skills/ (capture current state)
#   ./tools/sync-skills.sh status   — Show differences between the two

BUILD_SKILLS="/Users/jasonl/Desktop/Claudes-Man&Man-build/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"
CONFIG_SRC="/Users/jasonl/Desktop/Claudes-Man&Man-build/claude-config"
CLAUDE_CONFIG="$HOME/.claude"

ACTION="${1:-status}"

case "$ACTION" in
  deploy)
    echo "Deploying skills from build folder → ~/.claude/skills/"
    rsync -av --delete "$BUILD_SKILLS/" "$CLAUDE_SKILLS/"
    echo ""
    echo "Deploying hooks and commands..."
    rsync -av "$CONFIG_SRC/hooks/" "$CLAUDE_CONFIG/hooks/"
    rsync -av "$CONFIG_SRC/commands/" "$CLAUDE_CONFIG/commands/"
    echo "Done. Skills are live."
    ;;

  backup)
    echo "Backing up ~/.claude/skills/ → build/skills/"
    rsync -av --delete "$CLAUDE_SKILLS/" "$BUILD_SKILLS/"
    echo ""
    echo "Backing up hooks and commands..."
    rsync -av "$CLAUDE_CONFIG/hooks/" "$CONFIG_SRC/hooks/"
    rsync -av "$CLAUDE_CONFIG/commands/" "$CONFIG_SRC/commands/"
    echo "Done. Commit the build folder to save."
    ;;

  status)
    echo "=== Skills diff (build ↔ ~/.claude/skills) ==="
    diff -rq "$BUILD_SKILLS" "$CLAUDE_SKILLS" 2>/dev/null || echo "(no differences or one side is empty)"
    echo ""
    echo "Build skills: $(ls "$BUILD_SKILLS" 2>/dev/null | wc -l | tr -d ' ') items"
    echo "Claude skills: $(ls "$CLAUDE_SKILLS" 2>/dev/null | wc -l | tr -d ' ') items"
    ;;

  *)
    echo "Usage: $0 [deploy|backup|status]"
    exit 1
    ;;
esac
