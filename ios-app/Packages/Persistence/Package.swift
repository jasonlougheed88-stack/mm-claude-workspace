// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Persistence",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Persistence", targets: ["Persistence"])
    ],
    dependencies: [
        .package(path: "../CoreTaxonomy")
    ],
    targets: [
        .target(
            name: "Persistence",
            dependencies: [.product(name: "CoreTaxonomy", package: "CoreTaxonomy")],
            resources: [.process("ManifestAndMatch.xcdatamodeld")]
        ),
        .testTarget(name: "PersistenceTests", dependencies: ["Persistence"])
    ]
)
