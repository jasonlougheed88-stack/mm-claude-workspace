# Phase 2 — Loop Verification

## Goal
Prove the full learning loop works: swipe → update → persist → better results.

## Test Protocol
1. Fresh install — note starting alpha/beta (should be 1.0/1.0)
2. Swipe right 20× on tech/software jobs
3. Run check_thompson_state.sh — confirm alpha drifted up
4. Close app completely
5. Reopen — run check_thompson_state.sh — confirm params survived
6. Check deck order — tech jobs should dominate

## Success Criteria
- Alpha > 3.0 after 20 right swipes on a category
- Params survive app kill
- Deck composition visibly shifts toward preferred category

## Debug Overlay
Hidden behind 5-tap on score badge in DeckScreen.
Shows: amber alpha/beta, teal alpha/beta, profile blend position, confidence score.
