Create a new upgrade/feature branch and folder structure for: $ARGUMENTS

## Step 1: Create GitHub branch
```bash
cd "/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8"
git checkout -b feature/$ARGUMENTS
```

## Step 2: Create work folder in build directory
Location: `/Users/jasonl/Desktop/Claudes-Man&Man-build/session-notes/$ARGUMENTS/`

Create these files:

### PLAN.md
```markdown
# $ARGUMENTS — Plan

**Branch:** feature/$ARGUMENTS
**Status:** Planning
**Started:** [DATE]

## Objective
[What are we building/fixing and why?]

## Files to touch
- [ ] Package/path/file.swift

## Sacred constraints impact
- [ ] Swipe thresholds unchanged
- [ ] Amber/teal hues unchanged  
- [ ] Thompson <10ms preserved
- [ ] V7Core zero deps maintained

## Success criteria
1.
2.
```

### CHECKLIST.md
```markdown
# $ARGUMENTS — Checklist

## Implementation
- [ ] Code written
- [ ] Builds clean (no errors)
- [ ] Tested on device

## Validation
- [ ] Sacred constraints hook passes
- [ ] No performance regression
- [ ] Committed to feature branch

## Done
- [ ] PR created
- [ ] Merged to main
- [ ] Session notes updated
```

## Step 3: Remind me to commit frequently
Small commits per logical change. Branch naming: `feature/description-of-work`.
