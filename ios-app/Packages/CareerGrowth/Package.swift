// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "CareerGrowth",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "CareerGrowth", targets: ["CareerGrowth"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy"),
        .package(path: "../Persistence"),
        .package(path: "../ScoringEngine"),
        .package(path: "../Intelligence"),
        .package(path: "../Monitoring")
    ],
    targets: [
        .target(
            name: "CareerGrowth",
            dependencies: [
                .product(name: "CoreTaxonomy", package: "CoreTaxonomy"),
                .product(name: "Persistence", package: "Persistence"),
                .product(name: "ScoringEngine", package: "ScoringEngine"),
                .product(name: "Intelligence", package: "Intelligence"),
                .product(name: "Monitoring", package: "Monitoring")
            ]
        ),
        .testTarget(name: "CareerGrowthTests", dependencies: ["CareerGrowth"])
    ]
)
