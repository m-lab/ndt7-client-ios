// swift-tools-version:5.0
//
//  Package.swift
//  NDT7 iOS
//
//  Created by Miguel on 4/5/19.
//  Copyright © 2019 M-Lab. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "NDT7",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "NDT7",
            targets: ["NDT7"])
    ],
    targets: [
        .target(
            name: "NDT7",
            path: "Sources")
    ],
    swiftLanguageVersions: [.v5]
)
