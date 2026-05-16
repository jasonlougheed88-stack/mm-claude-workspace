// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SemanticMatch",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SemanticMatch", targets: ["SemanticMatch"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy")
    ],
    targets: [
        .target(
            name: "SemanticMatch",
            dependencies: [.product(name: "CoreTaxonomy", package: "CoreTaxonomy")]
        ),
        .testTarget(name: "SemanticMatchTests", dependencies: ["SemanticMatch"])
    ]
)
