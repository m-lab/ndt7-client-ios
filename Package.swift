// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "NDT7-TechSee",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_12),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "NDT7-TechSee",
            targets: ["NDT7-TechSee"]
        ),
    ],
    targets: [
        .target(
            name: "NDT7-TechSee",
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
