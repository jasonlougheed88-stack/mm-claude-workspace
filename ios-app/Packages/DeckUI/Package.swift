// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "DeckUI",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DeckUI", targets: ["DeckUI"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy"),
        .package(path: "../JobNormalizer"),
        .package(path: "../JobPipeline"),
        .package(path: "../ScoringEngine"),
        .package(path: "../Monitoring"),
        .package(path: "../Intelligence"),
        .package(path: "../Persistence"),
        .package(path: "../CareerGrowth")
    ],
    targets: [
        .target(
            name: "DeckUI",
            dependencies: [
                .product(name: "CoreTaxonomy", package: "CoreTaxonomy"),
                .product(name: "JobNormalizer", package: "JobNormalizer"),
                .product(name: "JobPipeline", package: "JobPipeline"),
                .product(name: "ScoringEngine", package: "ScoringEngine"),
                .product(name: "Monitoring", package: "Monitoring"),
                .product(name: "Intelligence", package: "Intelligence"),
                .product(name: "Persistence", package: "Persistence"),
                .product(name: "CareerGrowth", package: "CareerGrowth")
            ]
        ),
        .testTarget(name: "DeckUITests", dependencies: ["DeckUI"])
    ]
)
