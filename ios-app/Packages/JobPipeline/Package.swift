// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "JobPipeline",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "JobPipeline", targets: ["JobPipeline"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy"),
        .package(path: "../ScoringEngine"),
        .package(path: "../JobNormalizer"),
        .package(path: "../ResumeParsing"),
        .package(path: "../Persistence")
    ],
    targets: [
        .target(
            name: "JobPipeline",
            dependencies: [
                .product(name: "CoreTaxonomy", package: "CoreTaxonomy"),
                .product(name: "ScoringEngine", package: "ScoringEngine"),
                .product(name: "JobNormalizer", package: "JobNormalizer"),
                .product(name: "ResumeParsing", package: "ResumeParsing"),
                .product(name: "Persistence", package: "Persistence")
            ]
        ),
        .testTarget(name: "JobPipelineTests", dependencies: ["JobPipeline"])
    ]
)
