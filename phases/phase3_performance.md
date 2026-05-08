# Phase 3 — Startup Performance

## Current Bottlenecks (measured from Xcode console)
- O*NET cache pre-warm: 2923ms
- O*NET databases pre-load: 3655ms
- Total before deck usable: ~6.5 seconds

## Target
- First job card visible: < 1 second
- Full enrichment data available: < 3 seconds

## Strategy
1. Show deck immediately with basic job data (title, company, location)
2. Enrich cards progressively in background (O*NET scores, skill matches)
3. Move pre-warm to after first render, not before
4. Cache O*NET data to disk — only reload if data version changes

## Files
- `Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift` — pre-warm timing
- `Packages/V7Thompson/Sources/V7Thompson/ThompsonCache.swift` — cache strategy
