// swift-tools-version: 6.0

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Pathwise",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "Pathwise",
            targets: ["AppModule"],
            bundleIdentifier: "Zhang-Hongliang.Pathwise",
            teamIdentifier: "BYD6RXAK3G",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .lightningBolt),
            accentColor: .presetColor(.orange),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            appCategory: .education
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ],
    swiftLanguageVersions: [.version("6")]
)
