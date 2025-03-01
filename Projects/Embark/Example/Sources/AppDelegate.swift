import Apollo
import ApolloWebSocket
import Embark
import Flow
import Form
import Foundation
import hCore
import hGraphQL
import Presentation
import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	let bag = DisposeBag()

	func application(
		_: UIApplication,
		didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.makeKeyAndVisible()

		ApolloClient.saveToken(token: "tBmMTBw4OAPC5w==.TNrYtXtgMrDzxw==.KyJBBOTLaw1/Pg==")

		ApolloClient.initClient()
			.onValue { store, client in let navigationController = UINavigationController()
				navigationController.navigationBar.prefersLargeTitles = true
				self.window?.rootViewController = navigationController

				Dependencies.shared.add(module: Module { client })

				Dependencies.shared.add(module: Module { store })

				Localization.Locale.currentLocale = .en_NO
				DefaultStyling.installCustom()

				self.bag += navigationController.present(
					StoryList(),
					options: [.defaults, .largeTitleDisplayMode(.never)]
				)
			}
		return true
	}
}
