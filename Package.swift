// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Enhance",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "Enhance", targets: ["Enhance"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Enhance", dependencies: []),
    ]
)
