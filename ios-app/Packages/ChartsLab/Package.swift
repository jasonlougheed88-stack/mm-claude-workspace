// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "ChartsLab",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ChartsLab", targets: ["ChartsLab"])
    ],
    targets: [
        .target(name: "ChartsLab"),
        .testTarget(name: "ChartsLabTests", dependencies: ["ChartsLab"])
    ]
)
