// swift-tools-version: 6.1
import PackageDescription

// PHASE5-ADS: When Jason has AdMob credentials and sets USE_REAL_ADS in build settings:
// 1. Add to dependencies array:
//    .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.0.0")
// 2. Add to AdCards target dependencies:
//    .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
// 3. Add GADApplicationIdentifier to ManifestAndMatch/Info.plist
// 4. Add -D USE_REAL_ADS to Release build settings → Other Swift Flags

let package = Package(
    name: "AdCards",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AdCards", targets: ["AdCards"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy"),
        .package(path: "../Monitoring")
    ],
    targets: [
        .target(
            name: "AdCards",
            dependencies: [
                .product(name: "CoreTaxonomy", package: "CoreTaxonomy"),
                .product(name: "Monitoring", package: "Monitoring")
            ],
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"])
            ]
        ),
        .testTarget(name: "AdCardsTests", dependencies: ["AdCards"])
    ]
)
