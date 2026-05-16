// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "ProfileExtraction",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ProfileExtraction", targets: ["ProfileExtraction"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy"),
        .package(path: "../Persistence"),
        .package(path: "../CareerGrowth"),
        .package(path: "../Intelligence")
    ],
    targets: [
        .target(
            name: "ProfileExtraction",
            dependencies: [
                .product(name: "CoreTaxonomy", package: "CoreTaxonomy"),
                .product(name: "Persistence", package: "Persistence"),
                .product(name: "CareerGrowth", package: "CareerGrowth"),
                .product(name: "Intelligence", package: "Intelligence")
            ]
        ),
        .testTarget(name: "ProfileExtractionTests", dependencies: ["ProfileExtraction"])
    ]
)
