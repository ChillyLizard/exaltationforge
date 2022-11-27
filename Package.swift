// swift-tools-version:5.6
import PackageDescription
let package = Package(
    name: "ExaltationForge",
    platforms: [.macOS(.v11), .iOS(.v13)],
    products: [
        .executable(name: "ExaltationForge", targets: ["ExaltationForge"])
    ],
    dependencies: [
        .package(name: "Tokamak", url: "https://github.com/TokamakUI/Tokamak", from: "0.11.0")
    ],
    targets: [
        .executableTarget(
            name: "ExaltationForge",
            dependencies: [
                .product(name: "TokamakShim", package: "Tokamak")
            ]),
        .testTarget(
            name: "ExaltationForgeTests",
            dependencies: ["ExaltationForge"]),
    ]
)