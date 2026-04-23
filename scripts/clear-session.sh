#!/usr/bin/env bash
# Archives Doggies session summaries so the next session starts clean.
# Originals are moved to ~/.claude/session-data/archive/ — not deleted.
ARCHIVE_DIR="$HOME/.claude/session-data/archive"
SESSION_DIR="$HOME/.claude/session-data"
mkdir -p "$ARCHIVE_DIR"
moved=0
for f in "$SESSION_DIR"/*-Doggies-session.tmp; do
  [ -f "$f" ] || continue
  mv "$f" "$ARCHIVE_DIR/"
  echo "Archived: $(basename "$f")"
  ((moved++))
done
[ "$moved" -eq 0 ] && echo "No Doggies session files found." || echo "Done. Start a new Claude Code session for a clean slate."
