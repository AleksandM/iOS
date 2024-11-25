// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let settings: [SwiftSetting] = [
    .unsafeFlags(["-warnings-as-errors"]),
    .enableExperimentalFeature("ExistentialAny")
]

let package = Package(
    name: "CloudDrive",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CloudDrive",
            targets: ["CloudDrive"])
    ],
    dependencies: [
        .package(path: "../../../Domain/MEGADomain"),
        .package(path: "../../../Presentation/MEGAL10n"),
        .package(path: "../../../UI/MEGASwiftUI"),
        .package(url: "https://github.com/meganz/MEGADesignToken", branch: "main"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CloudDrive",
            dependencies: [
                "MEGADesignToken",
                "MEGADomain",
                "MEGAL10n",
                "MEGASwiftUI"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "CloudDriveTests",
            dependencies: [
                "CloudDrive",
                .product(
                    name: "MEGADomainMock",
                    package: "MEGADomain"
                ),
                .product(
                    name: "AsyncAlgorithms",
                    package: "swift-async-algorithms"
                )
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
