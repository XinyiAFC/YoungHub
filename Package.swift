// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YoungHub",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "YoungHub",
            targets: ["YoungHub"]
        ),
    ],
    targets: [
        .target(
            name: "YoungHub",
            path: "Sources"
        ),
    ]
)