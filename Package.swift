// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "DependencyFetcher",
    products: [
        .library(name: "DependencyFetcher", targets: ["DependencyFetcher"])
    ],
    targets: [
        .target(name: "DependencyFetcher"),
        .testTarget(name: "DependencyFetcherTests",
                    dependencies: ["DependencyFetcher"])
    ]
)
