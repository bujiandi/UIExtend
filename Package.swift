// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIExtend",
    platforms: [
        .iOS("8.0"),
        .watchOS("2.0"),
        .tvOS("9.0"),
    ],
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
            name: "OperatorLayout",
            targets: ["OperatorLayout"]),
        .library(
            name: "Refresh",
            targets: ["Refresh"]),
        .library(
            name: "Toast",
            targets: ["Toast"]),
        .library(
            name: "SceneManager",
            targets: ["SceneManager"]),
        .library(
            name: "BorderCorner",
            targets: ["BorderCorner"]),
        .library(
            name: "GradientColor",
            targets: ["GradientColor"]),
        .library(
            name: "EndEdit",
            targets: ["EndEdit"]),
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
//            dependencies: ["ImageCache","Toast"],
            dependencies: ["ImageCache","Toast","SceneManager"],
            linkerSettings: [
                .linkedFramework("UIKit"),
            ]),
        .testTarget(
            name: "UIExtendTests",
            dependencies: ["UIExtend"]),
        .target(
            name: "OperatorLayout",
            dependencies: [],
            linkerSettings: [
                .linkedFramework("UIKit"),
            ]),
        .target(
            name: "Toast",
            dependencies: ["OperatorLayout","CoreAnimations"],
            linkerSettings: [
                .linkedFramework("UIKit"),
            ]),
        .target(
            name: "Refresh",
            dependencies: ["OperatorLayout","CoreAnimations"],
            linkerSettings: [
                .linkedFramework("UIKit"),
            ]),
        .target(
            name: "ImageCache",
            dependencies: ["JSON","HTTP","Extend"],
            linkerSettings: [
                .linkedFramework("UIKit"),
            ]),
        .target(
            name: "ImagePreview",
            dependencies: ["ImageCache"],
            linkerSettings: [
                .linkedFramework("UIKit"),
            ]),
        .target(
            name: "SceneManager",
            dependencies: ["Adapter","Toast"],
            linkerSettings: [
                .linkedFramework("UIKit"),
            ]),
        .target(
            name: "BorderCorner",
            dependencies: [],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("QuartzCore"),
            ]),
        .target(
            name: "GradientColor",
            dependencies: [],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("QuartzCore"),
            ]),
        .target(
            name: "EndEdit",
            dependencies: [],
            linkerSettings: [
                .linkedFramework("UIKit"),
            ]),
        .target(
            name: "DynamicLayout",
            dependencies: ["OperatorLayout"],
            linkerSettings: [
                .linkedFramework("UIKit"),
            ]),
    ]
)
