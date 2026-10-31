// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PPBluetoothKit",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "PPBluetoothKit", targets: ["PPBluetoothKit"])
    ],
    targets: [
        .binaryTarget(
            name: "PPBluetoothKit",
            url: "https://github.com/LefuHengqi/PPBluetoothKit/releases/download/1.2.49/PPBluetoothKit-1.2.49.xcframework.zip",
            checksum: "d870fb2c36594183a8ac39980651f730fc5e526480744def973c7ee3ff2d9b49"
        )
    ]
)