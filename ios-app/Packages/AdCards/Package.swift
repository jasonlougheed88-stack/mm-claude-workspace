// swift-tools-version: 6.1
import PackageDescription

// PRODUCTION: Replace test ad unit ID in NativeAdLoader.swift before App Store submission.
// Replace GADApplicationIdentifier in Info.plist with real AdMob App ID.

let package = Package(
    name: "AdCards",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AdCards", targets: ["AdCards"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy"),
        .package(path: "../Monitoring"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.0.0")
    ],
    targets: [
        .target(
            name: "AdCards",
            dependencies: [
                .product(name: "CoreTaxonomy", package: "CoreTaxonomy"),
                .product(name: "Monitoring", package: "Monitoring"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ],
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"])
            ]
        ),
        .testTarget(name: "AdCardsTests", dependencies: ["AdCards"])
    ]
)
