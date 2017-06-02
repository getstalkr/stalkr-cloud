import PackageDescription

let package = Package(
    name: "stalkr-cloud",
    targets: [
        Target(name: "StalkrCloud"),
        Target(name: "App", dependencies: ["StalkrCloud"]),
        ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git",                 majorVersion: 2),
        .Package(url: "https://github.com/vapor/fluent-provider.git",       majorVersion: 1),
        .Package(url: "https://github.com/vapor/jwt.git",                   majorVersion: 2),
        .Package(url: "https://github.com/cardoso/more-fluent.git", majorVersion: 1)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

