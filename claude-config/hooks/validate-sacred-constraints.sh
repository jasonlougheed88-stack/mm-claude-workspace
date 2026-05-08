#!/bin/bash
# Sacred Constraints Validation Hook — V8
# Fires on every prompt. Validates nothing has broken the sacred constants.

V8_PATH="/Users/jasonl/Desktop/ios26_manifest_and_match/manifest_and_match_V8/Packages"
CORE="$V8_PATH/V7Core/Sources/V7Core"

VIOLATIONS=0

# CONSTRAINT 1: Swipe thresholds (SacredUIConstants.swift)
if grep -q "rightThreshold.*CGFloat" "$CORE/SacredUIConstants.swift" 2>/dev/null; then
    if ! grep -q "rightThreshold: CGFloat = 100" "$CORE/SacredUIConstants.swift" 2>/dev/null; then
        echo "❌ SACRED VIOLATION: rightThreshold must be 100"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
fi

if grep -q "leftThreshold.*CGFloat" "$CORE/SacredUIConstants.swift" 2>/dev/null; then
    if ! grep -q "leftThreshold: CGFloat = -100" "$CORE/SacredUIConstants.swift" 2>/dev/null; then
        echo "❌ SACRED VIOLATION: leftThreshold must be -100"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
fi

if grep -q "upThreshold.*CGFloat" "$CORE/SacredUIConstants.swift" 2>/dev/null; then
    if ! grep -q "upThreshold: CGFloat = -80" "$CORE/SacredUIConstants.swift" 2>/dev/null; then
        echo "❌ SACRED VIOLATION: upThreshold must be -80"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
fi

# CONSTRAINT 2: Amber/Teal hues
if grep -q "amberHue" "$CORE/SacredUIConstants.swift" 2>/dev/null; then
    if ! grep -q "amberHue.*45.0 / 360.0" "$CORE/SacredUIConstants.swift" 2>/dev/null; then
        echo "❌ SACRED VIOLATION: amberHue must be 45.0/360.0"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
fi

if grep -q "tealHue" "$CORE/SacredUIConstants.swift" 2>/dev/null; then
    if ! grep -q "tealHue.*174.0 / 360.0" "$CORE/SacredUIConstants.swift" 2>/dev/null; then
        echo "❌ SACRED VIOLATION: tealHue must be 174.0/360.0"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
fi

# CONSTRAINT 3: Thompson performance target
if grep -rq "thompsonSamplingTarget" "$V8_PATH/V7Core/Sources/V7Core/" 2>/dev/null; then
    if ! grep -rq "thompsonSamplingTarget.*0.010" "$V8_PATH/V7Core/Sources/V7Core/" 2>/dev/null; then
        echo "❌ SACRED VIOLATION: Thompson target must be 0.010 (10ms)"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
fi

# CONSTRAINT 4: V7Core must have zero external dependencies
if grep -q "\.package(url:" "$V8_PATH/V7Core/Package.swift" 2>/dev/null; then
    echo "❌ SACRED VIOLATION: V7Core must have zero external dependencies"
    VIOLATIONS=$((VIOLATIONS + 1))
fi

if [ $VIOLATIONS -gt 0 ]; then
    echo ""
    echo "🚫 $VIOLATIONS sacred constraint(s) violated. Fix before continuing."
    echo ""
fi

exit 0
