#!/bin/bash
# build.sh — Build M&M for physical device
# Usage: ./tools/build.sh [clean]

WORKSPACE="/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/ManifestAndMatchV7.xcworkspace"
SCHEME="ManifestAndMatchV7"
DEVICE_ID="00008140-001244112E43801C"

if [ "$1" == "clean" ]; then
  echo "Cleaning build..."
  xcodebuild clean -workspace "$WORKSPACE" -scheme "$SCHEME" 2>&1 | tail -5
fi

echo "Building for device..."
xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -destination "id=$DEVICE_ID" \
  -configuration Debug \
  2>&1 | grep -E "error:|warning:|BUILD SUCCEEDED|BUILD FAILED|Compiling" | tail -30
