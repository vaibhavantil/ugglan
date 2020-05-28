import ProjectDescription
import ProjectDescriptionHelpers

let sdkFrameworks: [TargetDependency] = [
    .sdk(name: "libc++.tbd"),
    .sdk(name: "libz.tbd"),
    .sdk(name: "SwiftUI.framework", status: .optional),
    .sdk(name: "SceneKit.framework"),
    .sdk(name: "AdSupport.framework"),
]

let ugglanConfigurations: [CustomConfiguration] = [
    .debug(name: "Debug", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
    .release(name: "Release", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
]

let hedvigConfigurations: [CustomConfiguration] = [
    .debug(name: "Debug", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_PRODUCTION"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
    .release(name: "Release", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_PRODUCTION"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
]

let testsConfigurations: [CustomConfiguration] = [
    .debug(name: "Debug", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
    .release(name: "Release", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
]

let projectFrameworkDependencies: [TargetDependency] = [
    .project(target: "hCore", path: .relativeToRoot("Projects/hCore")),
    .project(target: "hCoreUI", path: .relativeToRoot("Projects/hCoreUI")),
]

let appDependencies: [TargetDependency] = [
    projectFrameworkDependencies,
    sdkFrameworks,
    ExternalDependencies.allCases.map { externalDependency in
        externalDependency.targetDependencies()
    }.flatMap { $0 },
].flatMap { $0 }

let project = Project(
    name: "Ugglan",
    organizationName: "Hedvig",
    packages: [.package(url: "https://github.com/apollographql/apollo-ios.git", .upToNextMajor(from: "0.27.1"))],
    targets: [
        Target(
            name: "Ugglan",
            platform: .iOS,
            product: .app,
            bundleId: "com.hedvig.test.app",
            deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad]),
            infoPlist: "Config/Test/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**", "Config/Test/Resources/**"],
            actions: [],
            dependencies: [
                appDependencies,
                [.target(name: "WatchApp")]
            ].flatMap { $0 },
            settings: Settings(configurations: ugglanConfigurations)
        ),
        Target(
            name: "AppTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.hedvig.AppTests",
            deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad]),
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [
                [.target(name: "Ugglan"),
                 .framework(path: "../../Carthage/Build/iOS/SnapshotTesting.framework"),
                .project(target: "Testing", path: .relativeToRoot("Projects/Testing"))],
            ].flatMap { $0 },
            settings: Settings(configurations: testsConfigurations)
        ),
        Target(
            name: "Hedvig",
            platform: .iOS,
            product: .app,
            bundleId: "com.hedvig.app",
            deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad]),
            infoPlist: "Config/Production/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**", "Config/Production/Resources/**"],
            dependencies: appDependencies,
            settings: Settings(configurations: hedvigConfigurations)
        ),
         Target(name: "WatchApp",
                 platform: .watchOS,
                 product: .watch2App,
                 bundleId: "com.hedvig.test.app.watchApp",
                 infoPlist: .extendingDefault(with: [
                        "WKCompanionAppBundleIdentifier": "com.hedvig.test.app"
                 ]),
                 resources: "WatchExtension/App/**",
                 dependencies: [
                      .target(name: "WatchAppExtension")
                 ],
                 settings: Settings(configurations: testsConfigurations)
            ),
        Target(name: "WatchAppExtension",
                 platform: .watchOS,
                 product: .watch2Extension,
                 bundleId: "com.hedvig.test.app.watchApp.extension",
                 infoPlist: .extendingDefault(with: [
                        "CFBundleDisplayName": "WatchApp Extension"
                 ]),
                 sources: ["WatchExtension/Extension/**/*.swift", "WatchExtension/Sources/**/*.swift"],
                 resources: ["WatchExtension/Extension/**/*.xcassets"],
                 dependencies: [
                      .package(product: "Apollo"),
                      .package(product: "ApolloWebSocket")
                 ],
                 settings: Settings(configurations: testsConfigurations)
            )
    ],
    schemes: [
        Scheme(
            name: "Ugglan",
            shared: true,
            buildAction: BuildAction(targets: ["Ugglan"]),
            testAction: TestAction(
                targets: [TestableTarget(target: TargetReference(stringLiteral: "AppTests"), parallelizable: true)],
                          arguments: Arguments(environment: ["SNAPSHOT_ARTIFACTS": "/tmp/__SnapshotFailures__"], launch: [:])
                    ),
            runAction: RunAction(executable: "Ugglan")
        ),
        Scheme(
            name: "Hedvig",
            shared: true,
            buildAction: BuildAction(targets: ["Hedvig"]),
            runAction: RunAction(executable: "Hedvig")
        )
    ],
    additionalFiles: [
                          .folderReference(path: "WatchExtension/GraphQL")
                          ]
)
