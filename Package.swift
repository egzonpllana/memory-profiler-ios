// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MemoryProfiler",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "MemoryProfiler",
            targets: ["MemoryProfiler"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "MemoryProfiler",
            dependencies: []
        ),
    ]
) 
