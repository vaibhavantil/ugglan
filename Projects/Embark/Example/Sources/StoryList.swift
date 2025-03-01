import Apollo
import Embark
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct StoryList { @Inject var client: ApolloClient }

extension StoryList: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		let viewController = UIViewController()
		viewController.title = "Embark Stories"

		let plansButton = UIBarButtonItem(title: "Plans")
		viewController.navigationItem.rightBarButtonItem = plansButton

		let bag = DisposeBag()

		Localization.Locale.$currentLocale.value = .en_SE

		bag += plansButton.onValue { _ in
			bag +=
				viewController.present(
					EmbarkPlans(),
					options: [.defaults, .largeTitleDisplayMode(.never)]
				)
				.onValueDisposePrevious { story in
					viewController.present(
						Embark(name: story.name),
						options: [.defaults, .autoPop]
					)
					.nil()
				}
		}

		let tableKit = TableKit<EmptySection, StringRow>(holdIn: bag)
		bag += viewController.install(tableKit)

		bag += tableKit.delegate.didSelectRow.onValue { storyName in
			bag += viewController.present(
				Embark(name: storyName.value),
				options: [.defaults, .largeTitleDisplayMode(.never), .autoPop]
			)
		}

		bag += client.fetch(query: GraphQL.EmbarkStoryNamesQuery()).valueSignal.map { $0.embarkStoryNames }
			.compactMap { $0 }.map { $0.map { value in StringRow(value: value) } }
			.onValue { storyNames in tableKit.set(Table(rows: storyNames)) }

		return (viewController, bag)
	}
}
