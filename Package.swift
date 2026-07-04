// swift-tools-version:5.9

import PackageDescription
import Foundation

// Ainkrad fork: library-only. The upstream package also builds fuzz/termcast/
// benchmark executables and their external dependencies (argument-parser,
// docc-plugin, package-benchmark); Ainkrad consumes only the SwiftTerm
// library, and those extra deps drift into tool-version-incompatible releases.
// Trimming to the library keeps dependency resolution trivial and stable.

#if os(Linux) || os(Windows)
let platformExcludes = ["Apple", "Mac", "iOS"]
#else
let platformExcludes: [String] = []
#endif

let package = Package(
    name: "SwiftTerm",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .tvOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "SwiftTerm", targets: ["SwiftTerm"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftTerm",
            path: "Sources/SwiftTerm",
            exclude: platformExcludes + ["Mac/README.md"],
            resources: [
                .process("Apple/Metal/Shaders.metal")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
