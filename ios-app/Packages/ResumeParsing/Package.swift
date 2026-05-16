// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "ResumeParsing",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ResumeParsing", targets: ["ResumeParsing"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy"),
        .package(path: "../ScoringEngine"),
        .package(path: "../Monitoring")
    ],
    targets: [
        .target(
            name: "ResumeParsing",
            dependencies: [
                .product(name: "CoreTaxonomy", package: "CoreTaxonomy"),
                .product(name: "ScoringEngine", package: "ScoringEngine"),
                .product(name: "Monitoring", package: "Monitoring")
            ]
        ),
        .testTarget(name: "ResumeParsingTests", dependencies: ["ResumeParsing"])
    ]
)
