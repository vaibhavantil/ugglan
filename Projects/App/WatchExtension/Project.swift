import ProjectDescription
import ProjectDescriptionHelpers

let configurations: [CustomConfiguration] = [
    .debug(name: "Debug", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
    .release(name: "Release", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
]

let project = Project(name: "Watch",
targets: [
  Target(name: "WatchApp",
         platform: .watchOS,
         product: .watch2App,
         bundleId: "com.hedvig.test.app.watchApp",
         infoPlist: .extendingDefault(with: [
                "WKCompanionAppBundleIdentifier": "com.hedvig.test.app"
         ]),
         resources: "App/**",
         dependencies: [
              .target(name: "WatchAppExtension")
         ],
         settings: Settings(configurations: configurations)
    ),
Target(name: "WatchAppExtension",
         platform: .watchOS,
         product: .watch2Extension,
         bundleId: "com.hedvig.test.app.watchApp.extension",
         infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "WatchApp Extension"
         ]),
         sources: ["Extension/**/*.swift"],
         resources: ["Extension/**/*.xcassets"],
         dependencies: [
              
         ],
         settings: Settings(configurations: configurations)
    )
])
