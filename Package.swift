// swift-tools-version:5.9

import PackageDescription
import Foundation

// Ainkrad fork: library-only. The upstream package also builds fuzz/termcast/
// benchmark executables and their external dependencies (argument-parser,
// docc-plugin, package-benchmark); Ainkrad consumes only the SwiftTerm
// library, and those extra deps drift into tool-version-incompatible releases.
// Trimming to the library keeps dependency resolution trivial and stable.
//
// Additional Ainkrad patches:
//  - Mouse reporting: release is explicit through sendEvent/sendMotion;
//    SGR emits m only on real release (no button-code inference); hover
//    motion uses the no-button code (3); wheel is delivered as buttons
//    64/65 when the app requests mouse; X10 tracking is press-only.
//  - Restored a dependency-free SwiftTermTests target (library-only trim
//    had dropped it) so the fork's own suite runs.
//  - File drag-drop and paste: dropping a file, or pasting a file copied in
//    Finder, inserts its shell-escaped path at the cursor.

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
        ),
        .testTarget(
            name: "SwiftTermTests",
            dependencies: ["SwiftTerm"],
            path: "Tests/SwiftTermTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
