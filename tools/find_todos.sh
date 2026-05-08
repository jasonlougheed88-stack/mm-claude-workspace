#!/bin/bash
# find_todos.sh — Find all TODO/FIXME/HACK/BROKEN markers in the codebase
# Usage: ./tools/find_todos.sh

SOURCE_ROOT="/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8"

echo "=== TODOs ==="
grep -rn "// TODO:" "$SOURCE_ROOT/Packages" "$SOURCE_ROOT/ManifestAndMatchV7Package" 2>/dev/null \
  | grep -v ".build/" | head -30

echo ""
echo "=== FIXMEs ==="
grep -rn "// FIXME:" "$SOURCE_ROOT/Packages" "$SOURCE_ROOT/ManifestAndMatchV7Package" 2>/dev/null \
  | grep -v ".build/" | head -20

echo ""
echo "=== Currently DISABLED sources ==="
grep -n "// register" "$SOURCE_ROOT/Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift" | head -20
