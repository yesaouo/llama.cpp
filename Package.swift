// swift-tools-version:5.5

import PackageDescription

var sources = [
    "src/llama.cpp",
    "src/llama-vocab.cpp",
    "src/llama-grammar.cpp",
    "src/llama-sampling.cpp",
    "src/unicode.cpp",
    "src/unicode-data.cpp",
    "ggml/src/ggml.c",
    "ggml/src/ggml-alloc.c",
    "ggml/src/ggml-backend.c",
    "ggml/src/ggml-quants.c",
    "ggml/src/ggml-aarch64.c",
]

var resources: [Resource] = []
var linkerSettings: [LinkerSetting] = []
var cSettings: [CSetting] =  [
    .define("NDEBUG"),  // 使用 NDEBUG 定義，而非 unsafe flag
]

#if canImport(Darwin)
sources.append("ggml/src/ggml-metal.m")
resources.append(.process("ggml/src/ggml-metal.metal"))
linkerSettings.append(.linkedFramework("Accelerate"))
cSettings.append(
    contentsOf: [
        .define("GGML_USE_ACCELERATE"),
        .define("GGML_USE_METAL")
    ]
)
#endif

#if os(Linux)
    cSettings.append(.define("_GNU_SOURCE"))
#endif

let package = Package(
    name: "llama",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .watchOS(.v4),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "llama", targets: ["llama"]),
    ],
    targets: [
        .target(
            name: "llama",
            path: ".",
            exclude: [
               "cmake",
               "examples",
               "scripts",
               "models",
               "tests",
               "CMakeLists.txt",
               "Makefile"
            ],
            sources: sources,
            resources: resources,
            publicHeadersPath: "spm-headers",
            cSettings: cSettings,
            linkerSettings: linkerSettings
        )
    ],
    cxxLanguageStandard: .cxx11
)
