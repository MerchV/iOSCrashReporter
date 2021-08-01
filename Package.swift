// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSCrashReporter",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(name: "iOSCrashReporter", targets: ["iOSCrashReporter"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "iOSCrashReporter",
            dependencies: [],
            resources: [
                .copy("plist")
            ]
        ),
        .testTarget(name: "iOSCrashReporterTests", dependencies: ["iOSCrashReporter"])
    ]
)
