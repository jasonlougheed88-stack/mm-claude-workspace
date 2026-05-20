// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "AppShell",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AppShell", targets: ["AppShell"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy"),
        .package(path: "../Persistence"),
        .package(path: "../JobNormalizer"),
        .package(path: "../SemanticMatch"),
        .package(path: "../ScoringEngine"),
        .package(path: "../Monitoring"),
        .package(path: "../ResumeParsing"),
        .package(path: "../JobPipeline"),
        .package(path: "../Intelligence"),
        .package(path: "../CareerGrowth"),
        .package(path: "../ProfileExtraction"),
        .package(path: "../DeckUI"),
        .package(path: "../AdCards")
    ],
    targets: [
        .target(
            name: "AppShell",
            dependencies: [
                .product(name: "CoreTaxonomy", package: "CoreTaxonomy"),
                .product(name: "Persistence", package: "Persistence"),
                .product(name: "JobNormalizer", package: "JobNormalizer"),
                .product(name: "SemanticMatch", package: "SemanticMatch"),
                .product(name: "ScoringEngine", package: "ScoringEngine"),
                .product(name: "Monitoring", package: "Monitoring"),
                .product(name: "ResumeParsing", package: "ResumeParsing"),
                .product(name: "JobPipeline", package: "JobPipeline"),
                .product(name: "Intelligence", package: "Intelligence"),
                .product(name: "CareerGrowth", package: "CareerGrowth"),
                .product(name: "ProfileExtraction", package: "ProfileExtraction"),
                .product(name: "DeckUI", package: "DeckUI"),
                .product(name: "AdCards", package: "AdCards")
            ]
        ),
        .testTarget(name: "AppShellTests", dependencies: ["AppShell"])
    ]
)
