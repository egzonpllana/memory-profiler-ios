// swift-tools-version: 6.0
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
        )
    ],
    targets: [
        .target(
            name: "MemoryProfilerNative",
            cSettings: [
                // Heap introspection reads a libobjc debugger symbol and locks malloc zones.
                // It is compiled into debug builds only so release binaries never reference it.
                .define("MP_HEAP_INTROSPECTION", to: "1", .when(configuration: .debug))
            ]
        ),
        .target(
            name: "MemoryProfiler",
            dependencies: ["MemoryProfilerNative"]
        ),
        .testTarget(
            name: "MemoryProfilerTests",
            dependencies: ["MemoryProfiler"]
        )
    ],
    swiftLanguageModes: [.v6]
)
