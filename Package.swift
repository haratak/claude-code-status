// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClaudeCodeStatus",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ClaudeCodeStatus",
            targets: ["ClaudeCodeStatus"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ClaudeCodeStatus",
            dependencies: [],
            path: "Sources/ClaudeCodeStatus"
        )
    ]
)