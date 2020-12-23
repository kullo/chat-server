// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "KulloChatServer",
    products: [
        .library(name: "ChatServer", targets: ["ChatServer"]),
        .library(name: "FluentServices", targets: ["FluentServices"]),
        .library(name: "Vapor2ChatServer", targets: ["Vapor2ChatServer"]),
        .executable(name: "Run", targets: ["Run"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent.git", .upToNextMajor(from: "2.5.1")),
        .package(url: "https://github.com/tiwoc/postgresql-driver.git", .branch("fix-custom-id")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "4.1.1")),
        .package(url: "https://github.com/tiwoc/swift-sodium.git", .branch("expose-blake2b")),
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.4.4")),
    ],
    targets: [
        .target(
            name: "ChatServer",
            dependencies: ["RxSwift", "Sodium"]
        ),
        .target(
            name: "FluentServices",
            dependencies: ["ChatServer", "Fluent", "PostgreSQLDriver"]
        ),
        .target(
            name: "Vapor2ChatServer",
            dependencies: ["ChatServer", "FluentServices", "Vapor"],
            exclude: ["Config", "Public", "Resources"]
        ),
        .target(name: "Run", dependencies: ["ChatServer", "FluentServices", "Vapor", "Vapor2ChatServer"]),
        .target(name: "ChatServerTesting", dependencies: ["ChatServer"]),
        .testTarget(name: "ChatServerTests", dependencies: ["ChatServer", "ChatServerTesting", "FluentServices"]),
        .testTarget(name: "Vapor2ChatServerTests", dependencies: ["ChatServerTesting", "Testing", "Vapor2ChatServer", "FluentServices"]),
    ]
)
