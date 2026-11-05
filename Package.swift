// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CurrencyToWords",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "CurrencyToWords", targets: ["CurrencyToWords"])
    ],
    targets: [
        .executableTarget(name: "CurrencyToWords")
    ]
)
