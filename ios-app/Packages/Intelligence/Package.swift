// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Intelligence",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Intelligence", targets: ["Intelligence"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy"),
        .package(path: "../Persistence"),
        .package(path: "../JobPipeline"),
        .package(path: "../ScoringEngine"),
        .package(path: "../Monitoring")
    ],
    targets: [
        .target(
            name: "Intelligence",
            dependencies: [
                .product(name: "CoreTaxonomy", package: "CoreTaxonomy"),
                .product(name: "Persistence", package: "Persistence"),
                .product(name: "JobPipeline", package: "JobPipeline"),
                .product(name: "ScoringEngine", package: "ScoringEngine"),
                .product(name: "Monitoring", package: "Monitoring")
            ]
        ),
        .testTarget(name: "IntelligenceTests", dependencies: ["Intelligence"])
    ]
)
