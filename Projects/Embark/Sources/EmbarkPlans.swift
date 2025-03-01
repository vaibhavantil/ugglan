import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import SnapKit
import UIKit

public typealias EmbarkStory = GraphQL.ChoosePlanQuery.Data.EmbarkStory

public struct EmbarkPlans {
	@Inject var client: ApolloClient
	let menu: Menu?
	let plansSignal = ReadWriteSignal<[GraphQL.ChoosePlanQuery.Data.EmbarkStory]>([])
	@ReadWriteState var selectedIndex = 0

	var selectedPlan: ReadSignal<EmbarkStory?> {
		$selectedIndex.withLatestFrom(plansSignal)
			.map { selected, plans in
				plans.enumerated().filter { (offset, _) -> Bool in offset == selected }.first?.element
			}
	}

	public init(menu: Menu? = nil) { self.menu = menu }
}

extension EmbarkPlans: Presentable {
	public func materialize() -> (UIViewController, FiniteSignal<EmbarkStory>) {
		let viewController = UIViewController()
		let bag = DisposeBag()

		let sectionStyle = SectionStyle.defaultStyle

		let dynamicSectionStyle = DynamicSectionStyle { _ in sectionStyle }

		viewController.navigationItem.title = L10n.OnboardingStartpage.screenTitle

		if let menu = menu {
			let optionsButton = UIBarButtonItem(
				image: hCoreUIAssets.menuIcon.image,
				style: .plain,
				target: nil,
				action: nil
			)
			viewController.navigationItem.rightBarButtonItem = optionsButton

			bag += optionsButton.attachSinglePressMenu(viewController: viewController, menu: menu)
		}

		let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)

		let tableKit = TableKit<String, PlanRow>(style: style, holdIn: bag)

		let containerView = UIView()
		containerView.backgroundColor = .brand(.primaryBackground())
		viewController.view = containerView

		containerView.addSubview(tableKit.view)

		let activityIndicator = UIActivityIndicatorView()
		activityIndicator.startAnimating()

		containerView.addSubview(activityIndicator)

		let buttonContainerView = UIView()
		buttonContainerView.backgroundColor = .clear
		containerView.addSubview(buttonContainerView)

		tableKit.view.snp.makeConstraints { make in make.top.trailing.leading.equalToSuperview() }

		buttonContainerView.snp.makeConstraints { make in
			make.bottom.equalToSuperview().inset(containerView.safeAreaInsets.bottom)
			make.leading.trailing.equalToSuperview().inset(16)
			make.height.lessThanOrEqualTo(50)
			make.top.equalTo(tableKit.view.snp.bottom).offset(20)
		}

		activityIndicator.snp.makeConstraints { make in make.center.equalToSuperview() }

		let continueButton = Button(
			title: L10n.OnboardingStartpage.continueButtonText,
			type: .standard(
				backgroundColor: UIColor.brand(.secondaryButtonBackgroundColor),
				textColor: UIColor.brand(.secondaryButtonTextColor)
			)
		)

		bag += containerView.add(continueButton) { buttonView in
			buttonView.snp.makeConstraints { make in
				make.bottom.equalToSuperview().inset(-buttonView.frame.height)
				make.leading.trailing.equalTo(buttonContainerView)
				make.width.equalToSuperview().inset(20)
			}

			bag += buttonView.didMoveToWindowSignal.delay(by: 0.1).take(first: 1)
				.animated(style: SpringAnimationStyle.heavyBounce()) { () in
					let viewHeight =
						buttonView.systemLayoutSizeFitting(.zero).height
						+ (buttonView.superview?.safeAreaInsets.bottom ?? 0)
					buttonView.transform = CGAffineTransform(translationX: 0, y: -viewHeight)
				}

			bag += buttonView.didLayoutSignal.onValue {
				let bottomInset = buttonView.frame.height - buttonView.safeAreaInsets.bottom
				let inset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
				tableKit.view.contentInset = inset
				tableKit.view.scrollIndicatorInsets = inset
			}
		}

		bag += client.fetch(query: GraphQL.ChoosePlanQuery(locale: Localization.Locale.currentLocale.rawValue))
			.valueSignal.compactMap { $0.embarkStories }
			.map { $0.filter { story in story.type == .appOnboarding } }
			.onValue {
				activityIndicator.removeFromSuperview()
				plansSignal.value = $0
				$selectedIndex.value = 0
			}

		func isSelected(offset: Int) -> ReadWriteSignal<Bool> {
			$selectedIndex.map { offset == $0 }
				.writable { isSelected in if isSelected { $selectedIndex.value = offset } }
		}

		bag += plansSignal.atOnce().compactMap { $0 }
			.onValue { plans in
				var table = Table(sections: [
					(
						"",
						plans.enumerated()
							.map { offset, story in
								PlanRow(
									title: story.title,
									discount: story.discount,
									message: story.description,
									gradientType: story.gradientViewPreset,
									isSelected: isSelected(offset: offset)
								)
							}
					)
				])
				table.removeEmptySections()
				tableKit.set(table)
			}

		return (
			viewController,
			FiniteSignal<EmbarkStory> { callback in
				bag += continueButton.onTapSignal.withLatestFrom(selectedPlan.atOnce().plain())
					.compactMap { _, story in story }.onValue { story in callback(.value(story)) }

				return bag
			}
		)
	}
}

extension GraphQL.ChoosePlanQuery.Data.EmbarkStory {
	fileprivate var discount: String? { metadata.compactMap { $0.asEmbarkStoryMetadataEntryPill }.first?.pill }

	fileprivate var gradientViewPreset: GradientView.Preset {
		let background =
			metadata.compactMap { $0.asEmbarkStoryMetadataEntryBackground?.background }.first
			?? .gradientOne

		switch background {
		case .gradientOne: return .insuranceOne
		case .gradientTwo: return .insuranceTwo
		case .gradientThree: return .insuranceThree
		case .__unknown: return .insuranceOne
		}
	}
}
