// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BraceCompiler",
    dependencies: [
        .package(url: "https://github.com/llvm-swift/cllvm.git", .branch("master")),
    ],
    targets: [
        .target(name: "BraceCompiler", dependencies: []),
    ]
)
