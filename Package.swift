// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Wandr",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Wandr",
            targets: ["Wandr"]
        ),
        .executable(
            name: "WandrSelfCheck",
            targets: ["WandrSelfCheck"]
        ),
        .library(
            name: "WandrCore",
            targets: ["WandrCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WandrCore",
            dependencies: [],
            path: "Sources/WandrCore"
        ),
        .executableTarget(
            name: "Wandr",
            dependencies: ["WandrCore"],
            path: "Sources/WandrApp",
            exclude: ["Info.plist", "Assets.xcassets"]
        ),
        .executableTarget(
            name: "WandrSelfCheck",
            dependencies: ["WandrCore"],
            path: "Sources/WandrSelfCheck"
        )
    ]
)
