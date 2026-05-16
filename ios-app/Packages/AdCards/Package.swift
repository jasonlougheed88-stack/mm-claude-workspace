// swift-tools-version: 6.1
import PackageDescription

// Phase 5 only — NOT linked into AppShell until ad activation.
let package = Package(
    name: "AdCards",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AdCards", targets: ["AdCards"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy"),
        .package(path: "../DeckUI"),
        .package(path: "../Monitoring")
    ],
    targets: [
        .target(
            name: "AdCards",
            dependencies: [
                .product(name: "CoreTaxonomy", package: "CoreTaxonomy"),
                .product(name: "DeckUI", package: "DeckUI"),
                .product(name: "Monitoring", package: "Monitoring")
            ]
        ),
        .testTarget(name: "AdCardsTests", dependencies: ["AdCards"])
    ]
)
