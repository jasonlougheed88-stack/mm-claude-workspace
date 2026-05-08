---
name: performance-regression-detector
description: Detects performance regressions by running automated benchmarks before and after code changes, catching violations of the sacred <10ms Thompson requirement and other performance budgets
allowed-tools:
  - Read
  - Bash
  - Grep
  - Edit
---

# Performance Regression Detector

## Purpose

Automatically detects performance regressions when code changes are made, protecting the **357x competitive advantage** by catching slowdowns before they ship. Runs benchmarks, compares against baselines, and alerts when budgets are violated.

## Sacred Performance Budgets (Never Violate)

```yaml
Thompson Scoring: <10ms per job (CRITICAL - 357x advantage)
Memory Baseline: <200MB sustained
Memory Maximum: <250MB absolute limit
Tab Switching: <16ms transition
API Response: <3s company APIs, <2s RSS feeds
Question Generation: <40ms with cache
Ad Injection: <1ms (0ms target)
Skills Gap Analysis: <100ms
```

## When This Skill Activates

**Before code changes:**
- User asks "Will this break performance?"
- User requests "Run performance tests"
- Before merging code that touches Thompson, scoring, or hot paths

**After code changes:**
- User says "Check for regressions"
- After editing Thompson Sampling code
- After modifying scoring algorithms
- After changing caching logic

**Continuous monitoring:**
- User enables "Watch performance"
- During development sessions

## Workflow

### 1. Establish Baseline

Before making changes, capture current performance:

```bash
# Run baseline benchmarks
cd /path/to/v_7_uppgrade
swift test --filter PerformanceTests

# Capture metrics
./scripts/capture_baseline.sh > /tmp/baseline_metrics.json
```

**Baseline Metrics Captured:**
- Thompson scoring time per job (target: <10ms, actual: ~0.028ms)
- Memory usage across all tabs
- Tab switch latency
- API response times
- Cache hit rates

### 2. Make Code Changes

User edits code (Thompson, scoring, caching, etc.)

### 3. Run Regression Tests

After changes, automatically compare:

```bash
# Run performance tests again
swift test --filter PerformanceTests

# Compare against baseline
./scripts/detect_regression.sh /tmp/baseline_metrics.json

# Output: Pass/Fail with detailed breakdown
```

### 4. Alert on Violations

If regression detected:

```
🚨 PERFORMANCE REGRESSION DETECTED

Thompson Scoring:
  Baseline: 0.028ms per job
  Current:  12.5ms per job
  Status:   ❌ VIOLATED <10ms budget by 25%

Memory Usage:
  Baseline: 185MB
  Current:  195MB
  Status:   ✅ Within 200MB budget

Recommendation:
  - Revert changes to OptimizedThompsonEngine.swift:142
  - Cache precomputation is causing overhead
  - Review SIMD vectorization
```

## Detection Patterns

### Pattern 1: Thompson Scoring Regression

**Detect:**
```swift
// BEFORE: Fast scoring (0.028ms)
func scoreJobs(_ jobs: [Job]) async -> [ScoredJob] {
    let scores = jobs.map { scoreFast($0) }  // SIMD optimized
    return scores
}

// AFTER: Slow scoring (potential regression)
func scoreJobs(_ jobs: [Job]) async -> [ScoredJob] {
    var scores: [ScoredJob] = []
    for job in jobs {
        let score = await scoreWithNetworkCall(job)  // ⚠️ Async call added!
        scores.append(score)
    }
    return scores
}
```

**Alert:**
```
⚠️  Async network call added to hot path
⚠️  Loop now has await inside (blocks on each iteration)
⚠️  Potential 100x+ slowdown

Suggested fix:
- Move network calls outside scoring loop
- Use batch preloading
- Keep scoring synchronous
```

### Pattern 2: Memory Allocation Regression

**Detect:**
```swift
// BEFORE: Pre-allocated buffer (fast)
var scores = [Double](repeating: 0.0, count: jobs.count)

// AFTER: Repeated allocations (slow)
var scores: [Double] = []
for job in jobs {
    let tempArray = [job.skill1, job.skill2, job.skill3]  // ⚠️ Allocation per job
    scores.append(tempArray.reduce(0, +))
}
```

**Alert:**
```
⚠️  Memory allocation inside loop detected
⚠️  Estimated 1000+ allocations for 100 jobs
⚠️  GC pressure will increase

Suggested fix:
- Pre-allocate buffers outside loop
- Use in-place updates
- Reduce intermediate arrays
```

### Pattern 3: Cache Bypass Regression

**Detect:**
```swift
// BEFORE: Cache check (fast)
if let cached = cache.getScore(jobId) {
    return cached  // 90% hit rate
}

// AFTER: Cache disabled (slow)
// if let cached = cache.getScore(jobId) {  // ⚠️ Commented out!
//     return cached
// }
let score = expensiveCalculation(job)  // Always runs
```

**Alert:**
```
⚠️  Cache check disabled or bypassed
⚠️  90% cache hit rate lost
⚠️  Performance will degrade 10x on cached cases

Suggested fix:
- Re-enable cache check
- Verify cache key generation
- Check cache TTL settings
```

## Automated Testing Scripts

### Script 1: Capture Baseline

```bash
#!/bin/bash
# scripts/capture_baseline.sh

echo "📊 Capturing performance baseline..."

# Run Thompson performance tests
swift test \
  --filter V7ThompsonTests.PerformanceTests \
  --enable-test-discovery 2>&1 | \
  grep "measured" > /tmp/thompson_baseline.txt

# Run memory tests
swift test \
  --filter V7PerformanceTests.MemoryTests \
  --enable-test-discovery 2>&1 | \
  grep "MB" > /tmp/memory_baseline.txt

# Combine into JSON
cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "thompson_avg_ms": $(grep "Thompson" /tmp/thompson_baseline.txt | awk '{print $NF}'),
  "memory_baseline_mb": $(grep "Baseline" /tmp/memory_baseline.txt | awk '{print $NF}'),
  "cache_hit_rate": 0.90
}
EOF
```

### Script 2: Detect Regression

```bash
#!/bin/bash
# scripts/detect_regression.sh BASELINE_FILE

BASELINE=$1
CURRENT=$(mktemp)

# Capture current metrics
./scripts/capture_baseline.sh > "$CURRENT"

# Compare
python3 - <<EOF
import json
import sys

with open('$BASELINE') as f:
    baseline = json.load(f)

with open('$CURRENT') as f:
    current = json.load(f)

# Thompson check
thompson_baseline = float(baseline.get('thompson_avg_ms', 0.028))
thompson_current = float(current.get('thompson_avg_ms', 0.028))
thompson_budget = 10.0

print("=" * 80)
print("PERFORMANCE REGRESSION REPORT")
print("=" * 80)

# Thompson Scoring
print("\n🎯 Thompson Scoring:")
print(f"  Baseline: {thompson_baseline:.3f}ms per job")
print(f"  Current:  {thompson_current:.3f}ms per job")
print(f"  Budget:   <{thompson_budget:.1f}ms")

if thompson_current > thompson_budget:
    print(f"  Status:   ❌ VIOLATED by {((thompson_current/thompson_budget - 1) * 100):.1f}%")
    sys.exit(1)
elif thompson_current > thompson_baseline * 1.2:
    print(f"  Status:   ⚠️  DEGRADED by {((thompson_current/thompson_baseline - 1) * 100):.1f}%")
    sys.exit(1)
else:
    print(f"  Status:   ✅ PASS")

# Memory check
memory_baseline = float(baseline.get('memory_baseline_mb', 185))
memory_current = float(current.get('memory_baseline_mb', 185))
memory_budget = 200.0

print("\n💾 Memory Usage:")
print(f"  Baseline: {memory_baseline:.1f}MB")
print(f"  Current:  {memory_current:.1f}MB")
print(f"  Budget:   <{memory_budget:.1f}MB")

if memory_current > memory_budget:
    print(f"  Status:   ❌ VIOLATED")
    sys.exit(1)
elif memory_current > memory_baseline * 1.1:
    print(f"  Status:   ⚠️  INCREASED by {((memory_current/memory_baseline - 1) * 100):.1f}%")
else:
    print(f"  Status:   ✅ PASS")

print("\n" + "=" * 80)
print("✅ NO REGRESSIONS DETECTED")
print("=" * 80)
EOF
```

## Integration with Git Workflow

### Pre-Commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Auto-run regression detection before commit

echo "🔍 Checking for performance regressions..."

# Check if Thompson files changed
THOMPSON_CHANGED=$(git diff --cached --name-only | grep "V7Thompson")

if [ -n "$THOMPSON_CHANGED" ]; then
    echo "⚠️  Thompson code changed - running performance tests..."

    # Run regression detection
    ./scripts/detect_regression.sh /tmp/baseline_metrics.json

    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ Performance regression detected!"
        echo "❌ Commit blocked to protect <10ms requirement"
        echo ""
        echo "Options:"
        echo "  1. Fix the regression"
        echo "  2. Update baseline if intentional: ./scripts/capture_baseline.sh"
        echo "  3. Override (not recommended): git commit --no-verify"
        exit 1
    fi
fi

echo "✅ No regressions detected"
```

## Quick Commands

When using this skill, you can say:

**Before coding:**
- "Capture performance baseline"
- "What's the current Thompson performance?"

**During coding:**
- "Will this change affect performance?"
- "Check for hot path allocations"

**After coding:**
- "Run regression tests"
- "Compare against baseline"
- "Did I break the <10ms budget?"

**Analysis:**
- "Show performance trends"
- "Why did performance degrade?"
- "How do I fix this regression?"

## Reference Metrics

### Baseline Performance (V7 Current)

```yaml
Thompson Scoring:
  Average: 0.028ms per job
  P50: 0.025ms
  P95: 0.045ms
  P99: 0.080ms
  Budget: <10ms (357x margin)

Memory:
  Idle: 140MB
  Active: 185MB
  Peak: 195MB
  Budget: <200MB sustained

Tab Switching:
  Average: 8ms
  P95: 12ms
  Budget: <16ms

Cache Performance:
  Hit Rate: 90%+
  Lookup: <0.001ms
  TTL: 10 minutes
```

## Integration with Other Skills

This skill works alongside:

- **thompson-performance-guardian**: Enforces <10ms during development
- **v7-architecture-guardian**: Ensures architectural patterns don't cause regressions
- **cost-optimization-watchdog**: Tracks API call overhead

## Usage

This skill activates when you:
- Make changes to Thompson Sampling code
- Modify scoring algorithms
- Update caching logic
- Ask about performance impact
- Request regression testing
- Use keywords: "performance", "regression", "benchmark", "baseline"

The skill will automatically run tests, compare metrics, and alert you to any violations of performance budgets.

---

**Last Updated**: Created per user request
**Dependencies**: Swift test infrastructure, bash scripts
**Maintenance**: Update baselines after intentional performance improvements
