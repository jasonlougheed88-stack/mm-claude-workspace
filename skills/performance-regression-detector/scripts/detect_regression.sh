#!/bin/bash
# Detects performance regressions by comparing current metrics against baseline

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 BASELINE_FILE [PROJECT_ROOT]"
    echo "Example: $0 /tmp/baseline_metrics.json"
    exit 1
fi

BASELINE_FILE="$1"
PROJECT_ROOT="${2:-/Users/jasonl/Desktop/manifest and match  v7/V7 build files/v7codebase/Manifest_and_Match_V7_Working code base: instruction files /upgrade/v_7_uppgrade}"

if [ ! -f "$BASELINE_FILE" ]; then
    echo "❌ Baseline file not found: $BASELINE_FILE"
    echo "💡 Run: ./scripts/capture_baseline.sh > /tmp/baseline_metrics.json"
    exit 1
fi

echo "🔍 Detecting performance regressions..."
echo ""

# Capture current metrics
CURRENT_FILE=$(mktemp)
"$(dirname "$0")/capture_baseline.sh" "$PROJECT_ROOT" > "$CURRENT_FILE" 2>/dev/null

# Compare using Python
python3 - "$BASELINE_FILE" "$CURRENT_FILE" <<'PYTHON_SCRIPT'
import json
import sys
from datetime import datetime

if len(sys.argv) < 3:
    print("Error: Missing arguments")
    sys.exit(1)

baseline_file = sys.argv[1]
current_file = sys.argv[2]

try:
    with open(baseline_file) as f:
        baseline = json.load(f)
    with open(current_file) as f:
        current = json.load(f)
except Exception as e:
    print(f"❌ Error reading files: {e}")
    sys.exit(1)

# Extract metrics
thompson_baseline = float(baseline.get('thompson_avg_ms', 0.028))
thompson_current = float(current.get('thompson_avg_ms', 0.028))
thompson_budget = 10.0

memory_baseline = float(baseline.get('memory_baseline_mb', 185))
memory_current = float(current.get('memory_baseline_mb', 185))
memory_budget = 200.0
memory_critical = 250.0

cache_baseline = float(baseline.get('cache_hit_rate', 0.90))
cache_current = float(current.get('cache_hit_rate', 0.90))

# Print report
print("=" * 80)
print("PERFORMANCE REGRESSION DETECTION REPORT")
print("=" * 80)
print(f"\n📅 Baseline: {baseline.get('timestamp', 'unknown')}")
print(f"📅 Current:  {current.get('timestamp', 'unknown')}")
print()

has_regression = False
has_warning = False

# Thompson Scoring Check
print("🎯 Thompson Sampling Performance:")
print(f"  Baseline:  {thompson_baseline:.3f}ms per job")
print(f"  Current:   {thompson_current:.3f}ms per job")
print(f"  Budget:    <{thompson_budget:.1f}ms (SACRED)")

if thompson_current > thompson_budget:
    pct_over = ((thompson_current / thompson_budget) - 1) * 100
    print(f"  Status:    ❌ VIOLATED by {pct_over:.1f}%")
    print(f"  Impact:    357x advantage LOST!")
    has_regression = True
elif thompson_current > thompson_baseline * 1.2:
    pct_slower = ((thompson_current / thompson_baseline) - 1) * 100
    print(f"  Status:    ⚠️  DEGRADED by {pct_slower:.1f}%")
    has_warning = True
elif thompson_current > thompson_baseline * 1.05:
    pct_slower = ((thompson_current / thompson_baseline) - 1) * 100
    print(f"  Status:    ⚠️  Slightly slower by {pct_slower:.1f}%")
    has_warning = True
else:
    print(f"  Status:    ✅ PASS")

# Memory Check
print("\n💾 Memory Usage:")
print(f"  Baseline:  {memory_baseline:.1f}MB")
print(f"  Current:   {memory_current:.1f}MB")
print(f"  Budget:    <{memory_budget:.1f}MB sustained")
print(f"  Critical:  <{memory_critical:.1f}MB maximum")

if memory_current > memory_critical:
    print(f"  Status:    ❌ CRITICAL VIOLATION")
    has_regression = True
elif memory_current > memory_budget:
    pct_over = ((memory_current / memory_budget) - 1) * 100
    print(f"  Status:    ❌ VIOLATED by {pct_over:.1f}%")
    has_regression = True
elif memory_current > memory_baseline * 1.1:
    pct_increase = ((memory_current / memory_baseline) - 1) * 100
    print(f"  Status:    ⚠️  INCREASED by {pct_increase:.1f}%")
    has_warning = True
else:
    print(f"  Status:    ✅ PASS")

# Cache Hit Rate Check
print("\n💾 Cache Performance:")
print(f"  Baseline:  {cache_baseline * 100:.1f}% hit rate")
print(f"  Current:   {cache_current * 100:.1f}% hit rate")
print(f"  Target:    >90%")

if cache_current < 0.80:
    print(f"  Status:    ❌ CRITICAL (< 80%)")
    has_regression = True
elif cache_current < cache_baseline * 0.95:
    pct_drop = ((cache_baseline - cache_current) / cache_baseline) * 100
    print(f"  Status:    ⚠️  DEGRADED by {pct_drop:.1f}%")
    has_warning = True
else:
    print(f"  Status:    ✅ PASS")

# Summary
print("\n" + "=" * 80)
if has_regression:
    print("❌ PERFORMANCE REGRESSION DETECTED")
    print("=" * 80)
    print("\n🚫 BLOCKING: Code changes violate performance budgets")
    print("\n📋 Action Required:")
    print("  1. Review recent code changes")
    print("  2. Profile hot paths for bottlenecks")
    print("  3. Restore performance or update baseline")
    print("\n💡 Common causes:")
    print("  • Async calls in hot paths")
    print("  • Memory allocations inside loops")
    print("  • Cache bypass or disabled")
    print("  • SIMD optimization removed")
    sys.exit(1)
elif has_warning:
    print("⚠️  PERFORMANCE WARNING")
    print("=" * 80)
    print("\n⚠️  Performance degraded but within budgets")
    print("\n📋 Recommended Actions:")
    print("  1. Review if degradation is intentional")
    print("  2. Consider optimization opportunities")
    print("  3. Update baseline if acceptable")
    sys.exit(0)
else:
    print("✅ NO REGRESSIONS DETECTED")
    print("=" * 80)
    print("\n🎉 All performance metrics within acceptable ranges")
    print("✅ Safe to commit")
    sys.exit(0)

PYTHON_SCRIPT

# Cleanup
rm -f "$CURRENT_FILE"
