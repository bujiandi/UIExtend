// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIExtend",
    platforms: [.iOS("8.0"), .watchOS("2.0"), .tvOS("9.0")],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "UIExtend",
            targets: ["UIExtend"]),
        .library(
            name: "ImageCache",
            targets: ["ImageCache"]),
        .library(
            name: "ImagePreview",
            targets: ["ImagePreview"]),
        .library(
            name: "Toast",
            targets: ["Toast"]),
        .library(
            name: "SceneKit",
            targets: ["SceneKit"]),
        .library(
            name: "BorderCorner",
            targets: ["BorderCorner"]),
        .library(
            name: "DynamicLayout",
            targets: ["DynamicLayout"]),
    ],
    dependencies: [
        .package(path: "../Extend"),
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "UIExtend",
            dependencies: ["ImageCache","Toast","SceneKit"]),
        .testTarget(
            name: "UIExtendTests",
            dependencies: ["UIExtend"]),
        .target(
            name: "AutoLayout",
            dependencies: []),
        .target(
            name: "Toast",
            dependencies: ["AutoLayout","CoreAnimations"]),
        .target(
            name: "ImageCache",
            dependencies: ["JSON","HTTP","Extend"]),
        .target(
            name: "ImagePreview",
            dependencies: ["ImageCache"]),
        .target(
            name: "SceneKit",
            dependencies: ["UIKit"]),
        .target(
            name: "BorderCorner",
            dependencies: ["UIKit"]),
        .target(
            name: "DynamicLayout",
            dependencies: ["AutoLayout"]),
    ]
)
