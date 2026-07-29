// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "3Tap",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .target(
            name: "CMultitouch",
            dependencies: [],
            path: "Sources/CMultitouch",
            publicHeadersPath: "include"
        ),
        .executableTarget(
            name: "3Tap",
            dependencies: ["CMultitouch"],
            path: "Sources/3Tap"
        )
    ]
)
