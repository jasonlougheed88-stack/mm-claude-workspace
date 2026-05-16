// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Monitoring",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Monitoring", targets: ["Monitoring"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy"),
        .package(path: "../ScoringEngine")
    ],
    targets: [
        .target(
            name: "Monitoring",
            dependencies: [
                .product(name: "CoreTaxonomy", package: "CoreTaxonomy"),
                .product(name: "ScoringEngine", package: "ScoringEngine")
            ]
        ),
        .testTarget(name: "MonitoringTests", dependencies: ["Monitoring"])
    ]
)
