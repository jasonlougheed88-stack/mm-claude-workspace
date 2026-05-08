Run the V8 validation pipeline.

## Step 1: Build check
```bash
cd "/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8"
xcodebuild build \
  -workspace ManifestAndMatchV7.xcworkspace \
  -scheme ManifestAndMatchV7 \
  -destination "id=00008140-001244112E43801C" \
  -configuration Debug \
  2>&1 | grep -E "error:|BUILD SUCCEEDED|BUILD FAILED" | tail -20
```

## Step 2: Sacred constraints
```bash
bash ~/.claude/hooks/validate-sacred-constraints.sh
```

## Step 3: API connectivity
```bash
bash "/Users/jasonl/Desktop/Claudes-Man&Man-build/tools/check_api.sh"
```

## Step 4: Git status
```bash
cd "/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8"
git status --short | head -20
git log --oneline -5
```

## Pass criteria
- BUILD SUCCEEDED
- 0 sacred constraint violations
- API returns 200
- No unintended uncommitted changes

## Report
Save results to: `/Users/jasonl/Desktop/Claudes-Man&Man-build/session-notes/validation-$(date +%Y%m%d-%H%M%S).md`
