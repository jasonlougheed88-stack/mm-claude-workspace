#!/bin/bash
# check_thompson_state.sh — Read Thompson arm state from Core Data SQLite
# Shows current alpha/beta values to verify learning is persisting
# Usage: ./tools/check_thompson_state.sh

# Find the app's Core Data store on the device via local container
STORE_PATH=$(find ~/Library/Developer/CoreSimulator -name "V7DataModel.sqlite" 2>/dev/null | head -1)

if [ -z "$STORE_PATH" ]; then
  # Try device containers
  STORE_PATH=$(find ~/Library/Developer -name "V7DataModel.sqlite" 2>/dev/null | head -1)
fi

if [ -z "$STORE_PATH" ]; then
  echo "No Core Data store found. App must be run at least once."
  echo "For physical device, use Xcode → Devices → Download Container."
  exit 1
fi

echo "Store found: $STORE_PATH"
echo ""
echo "Thompson Arm State:"
sqlite3 "$STORE_PATH" "SELECT ZARMID, ZALPHA, ZBETA, ZLASTUPDATED FROM ZTHOMPSONARM ORDER BY ZLASTUPDATED DESC;" 2>/dev/null \
  || echo "Table not found or schema mismatch — check entity name in Core Data model"
