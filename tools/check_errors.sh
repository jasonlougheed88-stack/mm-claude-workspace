#!/bin/bash
# check_errors.sh — Build and show only errors
# Usage: ./tools/check_errors.sh

WORKSPACE="/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/ManifestAndMatchV7.xcworkspace"
SCHEME="ManifestAndMatchV7"
DEVICE_ID="00008140-001244112E43801C"

xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -destination "id=$DEVICE_ID" \
  -configuration Debug \
  2>&1 | grep -E "^.*error:.*$" | sort | uniq
