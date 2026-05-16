// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "ScoringEngine",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ScoringEngine", targets: ["ScoringEngine"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy"),
        .package(path: "../Persistence"),
        .package(path: "../JobNormalizer"),
        .package(path: "../SemanticMatch")
    ],
    targets: [
        .target(
            name: "ScoringEngine",
            dependencies: [
                .product(name: "CoreTaxonomy", package: "CoreTaxonomy"),
                .product(name: "Persistence", package: "Persistence"),
                .product(name: "JobNormalizer", package: "JobNormalizer"),
                .product(name: "SemanticMatch", package: "SemanticMatch")
            ]
        ),
        .testTarget(name: "ScoringEngineTests", dependencies: ["ScoringEngine"])
    ]
)
