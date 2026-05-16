import Foundation
import SwiftUI

/// Sacred UI Constants from V5.7 - NEVER CHANGE
/// These values preserve exact muscle memory and user interaction patterns
/// Any modification breaks the sacred contract with users
public enum SacredUI {

    /// Swipe gesture thresholds - exact values from V5.7
    public enum Swipe {
        public static let rightThreshold: CGFloat = 100
        public static let leftThreshold: CGFloat = -100
        public static let upThreshold: CGFloat = -80
        public static let rotationDivisor: CGFloat = 20.0
    }

    /// Animation timing - exact spring values from V5.7
    public enum Animation {
        public static let springResponse: Double = 0.6
        public static let springDamping: Double = 0.8
    }

    /// Card dimensions - exact proportions from V5.7
    public enum Card {
        public static let widthRatio: CGFloat = 0.92
        public static let heightRatio: CGFloat = 0.85
        public static let maxWidth: CGFloat = 520
        public static let maxHeight: CGFloat = 750
        public static let cornerRadius: CGFloat = 24
    }

    /// Dual Profile color system - Amber to Teal spectrum
    public enum DualProfile {
        /// Amber hue for current self (#FFBF00)
        public static let amberHue: Double = 45.0 / 360.0
        /// Teal hue for future self (#00BFA5)
        public static let tealHue: Double = 174.0 / 360.0
        public static let saturation: Double = 0.85
        public static let brightness: Double = 0.9
        public static let brandSaturation: Double = saturation
        public static let brandBrightness: Double = brightness
        public static let sacredAmber = Color(hue: amberHue, saturation: brandSaturation, brightness: brandBrightness)
        public static let sacredTeal = Color(hue: tealHue, saturation: brandSaturation, brightness: brandBrightness)
    }

    /// Spacing values - exact layout from V5.7
    public enum Spacing {
        public static let standard: CGFloat = 20
        public static let section: CGFloat = 16
        public static let compact: CGFloat = 12
        public static let button: CGFloat = 12
        public static let large: CGFloat = 24
        public static let small: CGFloat = 8
        public static let xsmall: CGFloat = 4
        public static let xxsmall: CGFloat = 2
        public static let cardPadding: CGFloat = 20
        public static let listItemSpacing: CGFloat = 12
    }

    public enum Button {
        public static let primaryHeight: CGFloat = 56
        public static let secondaryHeight: CGFloat = 48
        public static let quickActionSize: CGFloat = 44
        public static let cornerRadius: CGFloat = 12
        public static let minTouchTarget: CGFloat = 44
    }

    public enum CardStyle {
        public static let largeCornerRadius: CGFloat = 24
        public static let mediumCornerRadius: CGFloat = 16
        public static let smallCornerRadius: CGFloat = 12
        public static let xsmallCornerRadius: CGFloat = 8
        public static let tinyCornerRadius: CGFloat = 4
        public static let shadowRadius: CGFloat = 8
        public static let shadowRadiusLarge: CGFloat = 10
        public static let shadowOpacity: Double = 0.1
        public static let shadowY: CGFloat = 4
        public static let shadowYLarge: CGFloat = 5
    }

    public enum SemanticColor {
        public static let amber = Color(hue: DualProfile.amberHue, saturation: 0.85, brightness: 0.90)
        public static let teal = Color(hue: DualProfile.tealHue, saturation: 0.85, brightness: 0.90)
        public static let amberDark = Color(hue: DualProfile.amberHue, saturation: 0.85, brightness: 0.50)
        public static let tealDark = Color(hue: DualProfile.tealHue, saturation: 0.85, brightness: 0.50)
        public static let background = Color(white: 0.98)
        public static let surface = Color.white
        public static let surfaceDark = Color(white: 0.12)
        public static let border = Color(white: 0.9)
        public static let text = Color(white: 0.1)
        public static let textSecondary = Color(white: 0.4)
        public static let success = Color(hue: 120/360, saturation: 0.6, brightness: 0.7)
        public static let error = Color(hue: 0, saturation: 0.7, brightness: 0.85)
        public static let warning = Color(hue: 30/360, saturation: 0.85, brightness: 0.95)

        public enum Opacity {
            public static let disabled: Double = 0.4
            public static let selection: Double = 0.15
            public static let shadow: Double = 0.1
            public static let shadowSubtle: Double = 0.05
            public static let shadowProminent: Double = 0.15
            public static let overlay: Double = 0.8
        }
    }

    public enum Typography {
        public static let display1: Font = .system(size: 34, weight: .bold)
        public static let display2: Font = .system(size: 28, weight: .bold)
        public static let title1: Font = .system(size: 22, weight: .semibold)
        public static let title2: Font = .system(size: 20, weight: .semibold)
        public static let title3: Font = .system(size: 18, weight: .semibold)
        public static let body1: Font = .system(size: 17, weight: .regular)
        public static let body2: Font = .system(size: 15, weight: .regular)
        public static let caption1: Font = .system(size: 13, weight: .regular)
        public static let caption2: Font = .system(size: 11, weight: .regular)
        public static let buttonPrimary: Font = .system(size: 17, weight: .semibold)
        public static let buttonSecondary: Font = .system(size: 15, weight: .medium)
        public static let hero: Font = .system(size: 50, weight: .bold)
        public static let gaugeNumber: Font = .system(size: 32, weight: .bold, design: .rounded)
    }

    public enum Icon {
        public static let small: CGFloat = 16
        public static let medium: CGFloat = 20
        public static let large: CGFloat = 24
        public static let xlarge: CGFloat = 32
        public static let hero: CGFloat = 50
        public static let weight: Font.Weight = .medium
    }

    public enum ComponentSize {
        public static let minTouchTarget: CGFloat = 44
        public static let collapsibleHeaderHeight: CGFloat = 56
        public static let smallCardHeight: CGFloat = 80
        public static let mediumCardHeight: CGFloat = 120
        public static let largeCardHeight: CGFloat = 200
        public static let chipMinWidth: CGFloat = 80
        public static let chipHeight: CGFloat = 36
    }

    public enum AnimationPreset {
        public static let cardFlip = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.75)
        public static let sheetPresent = SwiftUI.Animation.easeInOut(duration: 0.35)
        public static let fadeIn = SwiftUI.Animation.easeIn(duration: 0.2)
        public static let fadeOut = SwiftUI.Animation.easeOut(duration: 0.15)
        public static let slideIn = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.85)
        public static let spring = SwiftUI.Animation.spring(response: Animation.springResponse, dampingFraction: Animation.springDamping)
    }
}

// MARK: - Performance Budget

public enum PerformanceBudget {
    /// Thompson Sampling sacred performance target: <10ms
    public static let thompsonSamplingTarget: TimeInterval = 0.010
    public static let apiResponseTarget: TimeInterval = 2.0
    public static let memoryBaselineMB: Double = 200.0
    public static let emergencyMemoryThresholdMB: Double = 250.0
    public static let highMemoryThresholdMB: Double = 220.0
    public static let moderateMemoryRatio: Double = 0.75
    public static let highMemoryRatio: Double = 0.80
    public static let emergencyMemoryRatio: Double = 0.90
    public static let companyAPITarget: TimeInterval = 3.0
    public static let rssFeedTarget: TimeInterval = 2.0
    public static let totalPipelineTarget: TimeInterval = 5.0
}

// MARK: - Runtime Validation

public struct SacredValueValidator {
    public static func validateAll() {
        assert(SacredUI.Swipe.rightThreshold == 100)
        assert(SacredUI.Swipe.leftThreshold == -100)
        assert(SacredUI.Swipe.upThreshold == -80)
        assert(SacredUI.Swipe.rotationDivisor == 20.0)
        assert(SacredUI.Animation.springResponse == 0.6)
        assert(SacredUI.Animation.springDamping == 0.8)
        assert(SacredUI.Card.widthRatio == 0.92)
        assert(SacredUI.Card.heightRatio == 0.85)
        assert(SacredUI.Card.maxWidth == 520)
        assert(SacredUI.Card.maxHeight == 750)
        assert(SacredUI.Card.cornerRadius == 24)
        assert(abs(SacredUI.DualProfile.amberHue - (45.0 / 360.0)) < 0.001)
        assert(abs(SacredUI.DualProfile.tealHue - (174.0 / 360.0)) < 0.001)
        assert(SacredUI.DualProfile.saturation == 0.85)
        assert(SacredUI.DualProfile.brightness == 0.9)
        assert(SacredUI.Spacing.standard == 20)
        assert(SacredUI.Spacing.section == 16)
        assert(SacredUI.Spacing.compact == 12)
        assert(SacredUI.Spacing.button == 12)
        assert(PerformanceBudget.thompsonSamplingTarget == 0.010)
        assert(PerformanceBudget.memoryBaselineMB == 200.0)
        assert(PerformanceBudget.emergencyMemoryThresholdMB == 250.0)
    }
}
