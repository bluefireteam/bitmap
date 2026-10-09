// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "bitmap",
  platforms: [.iOS("12.0")],
  products: [.library(name: "bitmap", targets: ["bitmap"])],
  dependencies: [.package(name: "FlutterFramework", path: "../FlutterFramework")],
  targets: [
    .target(name: "bitmap_cpp"),
    .target(name: "bitmap", dependencies: ["bitmap_cpp", .product(name: "FlutterFramework", package: "FlutterFramework")]),
  ]
)
