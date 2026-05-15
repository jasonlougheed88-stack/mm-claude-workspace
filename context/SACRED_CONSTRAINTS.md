# Sacred Constraints
**Source of truth (reference codebase):** `Packages/V7Core/Sources/V7Core/SacredUIConstants.swift`
**New build package:** `CoreTaxonomy` — file lives at same relative path inside CoreTaxonomy
Never change these values. They encode preserved muscle memory from V5.7.

---

## Swipe Thresholds (`SacredUI.Swipe`)
```swift
rightThreshold: CGFloat = 100     // "Interested"
leftThreshold:  CGFloat = -100    // "Pass"
upThreshold:    CGFloat = -80     // "Save for later"
rotationDivisor: CGFloat = 20.0
```

## Animation (`SacredUI.Animation`)
```swift
springResponse: Double = 0.6
springDamping:  Double = 0.8
```

## Card Dimensions (`SacredUI.Card`)
```swift
widthRatio:    CGFloat = 0.92   // 92% of screen width
heightRatio:   CGFloat = 0.85   // 85% of screen height
maxWidth:      CGFloat = 520
maxHeight:     CGFloat = 750
cornerRadius:  CGFloat = 24
```

## Dual Profile Colors (`SacredUI.DualProfile`)
```swift
amberHue:   Double = 45.0 / 360.0    // #FFBF00 — Current Self
tealHue:    Double = 174.0 / 360.0   // #00BFA5 — Future Self
saturation: Double = 0.85
brightness: Double = 0.9
```

## Performance Budget (`PerformanceBudget`)
```swift
thompsonSamplingTarget: TimeInterval = 0.010   // 10ms — most critical
apiResponseTarget:      TimeInterval = 2.0
memoryBaselineMB:       Double = 200.0
emergencyMemoryMB:      Double = 250.0
totalPipelineTarget:    TimeInterval = 5.0
```

## CoreTaxonomy Zero Dependencies
`CoreTaxonomy/Package.swift` must have zero `.package(url:)` entries.
Everything else depends on CoreTaxonomy. It depends on nothing.
(Reference codebase equivalent: `Packages/V7Core/Package.swift`)

---

## Runtime Validation
`SacredValueValidator.validateAll()` asserts all of the above at runtime.
If any assert fires, the app crashes with a descriptive message.
