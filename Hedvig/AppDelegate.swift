//
//  AppDelegate.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Apollo
import Katana
import Tempura
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RootInstaller {
    var window: UIWindow?
    var store: Store<AppState>!

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        store = Store<AppState>(middleware: [], dependencies: DependenciesContainer.self)

        window = UIWindow(frame: UIScreen.main.bounds)

        if let dependenciesContainer = self.store!.dependencies as? DependenciesContainer {
            let navigator: Navigator! = dependenciesContainer.navigator
            navigator.start(using: self, in: window!, at: Screen.chat)
        }

        return true
    }

    func installRoot(
        identifier: RouteElementIdentifier,
        context _: Any?,
        completion: () -> Void
    ) {
        if identifier == Screen.chat.rawValue {
            let chatViewController = ChatViewController(store: store)
            let navigationController = UINavigationController(rootViewController: chatViewController)
            window?.rootViewController = navigationController
            completion()
        }
    }
}
