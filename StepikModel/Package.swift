// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StepikModel",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(
            name: "StepikModel",
            targets: ["StepikModel"]
        )
    ],
    targets: [
        .target(
            name: "StepikModel",
            path: "Sources"
        ),
        .testTarget(
            name: "StepikModelTests",
            dependencies: ["StepikModel"]
        )
    ]
)
