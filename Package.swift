// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CurrencyToText",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "CurrencyToText", targets: ["CurrencyToText"])
    ],
    targets: [
        .executableTarget(name: "CurrencyToText")
    ]
)
