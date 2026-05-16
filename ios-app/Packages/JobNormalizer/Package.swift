// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "JobNormalizer",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "JobNormalizer", targets: ["JobNormalizer"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy")
    ],
    targets: [
        .target(
            name: "JobNormalizer",
            dependencies: [.product(name: "CoreTaxonomy", package: "CoreTaxonomy")]
        ),
        .testTarget(name: "JobNormalizerTests", dependencies: ["JobNormalizer"])
    ]
)
