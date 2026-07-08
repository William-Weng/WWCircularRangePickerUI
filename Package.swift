// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWCircularRangePickerUI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "WWCircularRangePickerUI",
            targets: ["WWCircularRangePickerUI"]
        ),
    ],
    targets: [
        .target(name: "WWCircularRangePickerUI", resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
