#!/bin/bash
# stream_logs.sh — Stream app logs while Xcode debug session is active
# Usage: ./tools/stream_logs.sh [filter]
# Example: ./tools/stream_logs.sh DeckScreen

SUBSYSTEM="com.manifest.match.v7"
FILTER="${1:-}"

if [ -n "$FILTER" ]; then
  /usr/bin/log stream \
    --predicate "subsystem == \"$SUBSYSTEM\" AND category == \"$FILTER\"" \
    --level debug
else
  /usr/bin/log stream \
    --predicate "subsystem == \"$SUBSYSTEM\"" \
    --level debug
fi
