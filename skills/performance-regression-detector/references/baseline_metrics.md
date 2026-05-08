# V7 Performance Baseline Metrics

This document tracks the known-good performance baselines for ManifestAndMatchV7.

## Last Updated: October 26, 2025

## Thompson Sampling Performance (CRITICAL)

**Sacred Budget: <10ms per job** (357x competitive advantage)

```yaml
Current Achieved Performance:
  Average:      0.028ms per job (357,142x faster than naive 10s)
  Median (P50): 0.025ms
  P95:          0.045ms
  P99:          0.080ms
  Max observed: 0.120ms

Margin of Safety:
  Target vs Actual: 357x (10ms vs 0.028ms)
  Budget remaining: 9.972ms (99.7% headroom)

Benchmark Configuration:
  Test suite: V7ThompsonTests.PerformanceTests
  Job count: 100 jobs per test
  Iterations: 1000 runs
  Environment: iPhone 15 Pro (A17 Pro)
```

## Memory Performance

**Baseline Budget: <200MB sustained**
**Critical Limit: <250MB absolute maximum**

```yaml
Current Memory Profile:
  App Launch:    140MB
  Idle State:    145MB
  Active Usage:  185MB (with 100 jobs loaded)
  Peak Load:     195MB (during Thompson scoring)

Margin of Safety:
  Baseline margin: 15MB (7.5% below budget)
  Critical margin: 55MB (22% below maximum)

Memory Breakdown:
  Swift Runtime:    45MB
  UI Framework:     35MB
  Job Data:         40MB
  Thompson Cache:   25MB
  Other:            40MB

Test Configuration:
  Test suite: V7PerformanceTests.MemoryTests
  Scenarios: Tab switching, job loading, scoring
  Instruments: Xcode Memory Profiler
```

## Cache Performance

**Target: >90% hit rate**

```yaml
Current Cache Metrics:
  Question Cache:   92% hit rate
  Thompson Cache:   91% hit rate
  Job Data Cache:   88% hit rate

  Overall:          90.3% average

Cache Configuration:
  Question TTL:     1 hour (3600s)
  Thompson TTL:     10 minutes (600s)
  Job Data TTL:     5 minutes (300s)
  Max cache size:   500 entries per cache

Performance Impact:
  Cache hit:        <0.001ms lookup
  Cache miss:       5-40ms (depends on source)
  Cost savings:     $0.05 per question cache hit
```

## UI Performance

**Tab Switching: <16ms target (60 FPS)**

```yaml
Current Tab Performance:
  Average:      8ms
  P50:          7ms
  P95:          12ms
  P99:          14ms
  Max observed: 15.5ms

Margin: 1ms below budget (within target)

Test Configuration:
  Test suite: V7UITests.NavigationTests
  Platform: iOS 18.4
  Device: iPhone 15 Pro
```

## API Response Times

**Company APIs: <3s**
**RSS Feeds: <2s**

```yaml
Current API Performance:
  Greenhouse:       1.2s average
  Lever:            1.4s average
  AngelList:        1.8s average
  LinkedIn:         2.1s average
  Remotive RSS:     0.8s average

All within budgets ✅

Configuration:
  Timeout: 5s per source
  Retry: 3 attempts with exponential backoff
  Circuit breaker: Open after 3 failures
```

## Question Generation

**Budget: <40ms with 90% cache hit**

```yaml
Current Performance:
  Cache hit:         <1ms (instant)
  Cache miss (AI):   35ms average
  Template fallback: 5ms

  Overall weighted:  8ms average (90% hit rate)

AI Service Breakdown:
  Token processing:  20ms
  Network latency:   10ms
  Response parsing:  5ms
  Total:            35ms

Within budget: ✅ (5ms margin)
```

## Ad Injection

**Target: 0ms impact (background preloading)**

```yaml
Current Performance:
  Injection logic:   0.5ms
  No network delay:  0ms (preloaded)

Total impact:        0.5ms (negligible)

Configuration:
  Preload buffer: 20 ads
  Placement ratio: 1:10 (1 ad per 10 jobs)
  Background refresh: Continuous
```

## Skills Gap Analysis

**Budget: <100ms acceptable for tab switch**

```yaml
Current Performance:
  Average:  45ms
  P95:      75ms
  P99:      90ms

  Within budget: ✅ (10ms margin)

Breakdown:
  Skill extraction:     10ms
  Fuzzy matching:       20ms
  Gap prioritization:   10ms
  Learning path gen:    5ms
```

## Regression Thresholds

Use these thresholds for regression detection:

```yaml
CRITICAL (Block commit):
  Thompson > 10ms:           ❌ Sacred budget violated
  Memory > 250MB:            ❌ Critical limit exceeded
  Cache hit rate < 80%:      ❌ Unacceptable degradation

WARNING (Review required):
  Thompson > baseline * 1.2: ⚠️  20% slower
  Memory > baseline * 1.1:   ⚠️  10% increase
  Cache rate < baseline * 0.95: ⚠️ 5% drop

ACCEPTABLE:
  Thompson < baseline * 1.05: ✅ Within 5% tolerance
  Memory < baseline * 1.05:   ✅ Within 5% tolerance
  Cache rate > 90%:           ✅ Target maintained
```

## Baseline Update Procedure

When to update baselines:

1. **Intentional optimization** (faster code):
   ```bash
   # Verify improvement is real
   ./scripts/detect_regression.sh /tmp/old_baseline.json

   # Capture new baseline
   ./scripts/capture_baseline.sh > /tmp/new_baseline.json

   # Document in this file
   git add references/baseline_metrics.md
   git commit -m "Update baseline after Thompson optimization"
   ```

2. **Platform upgrade** (iOS/Swift version):
   - Run full benchmark suite
   - Verify no regressions vs previous platform
   - Update baselines with platform notes

3. **Hardware change** (device upgrade):
   - Normalize to iPhone 15 Pro baseline
   - Or document new device baseline separately

## Historical Trends

Track baseline evolution:

| Date       | Thompson (ms) | Memory (MB) | Cache Hit % | Notes |
|------------|---------------|-------------|-------------|-------|
| 2025-10-26 | 0.028         | 185         | 90.3        | Initial V7 baseline |
| TBD        | -             | -           | -           | Future updates |

## Testing Commands

Reproduce baseline measurements:

```bash
# Full performance suite
cd /path/to/v_7_uppgrade
swift test --filter PerformanceTests

# Thompson only
swift test --filter V7ThompsonTests.PerformanceTests

# Memory only
swift test --filter V7PerformanceTests.MemoryTests

# Capture baseline
./scripts/capture_baseline.sh > /tmp/baseline_$(date +%Y%m%d).json

# Detect regressions
./scripts/detect_regression.sh /tmp/baseline_20251026.json
```
