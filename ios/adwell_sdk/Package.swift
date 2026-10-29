// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "adwell_sdk",
    platforms: [.iOS("14.0")],
    products: [
        .library(name: "adwell-sdk", targets: ["adwell_sdk"])
    ],
    dependencies: [
        // Keep in step with pubspec.yaml and the podspec (test/versions_test.dart).
        .package(url: "https://github.com/runadwell/adwell-ios", exact: "0.1.0")
    ],
    targets: [
        .target(
            name: "adwell_sdk",
            dependencies: [.product(name: "AdwellSDK", package: "adwell-ios")]
        )
    ]
)
