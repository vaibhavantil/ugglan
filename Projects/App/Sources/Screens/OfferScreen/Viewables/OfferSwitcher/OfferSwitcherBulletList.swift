import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct OfferSwitcherBulletList { @Inject var client: ApolloClient }

extension OfferSwitcherBulletList {
	struct BulletPoint: Viewable {
		let index: Int
		let text: String

		func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
			let bag = DisposeBag()
			let stackView = UIStackView()
			stackView.axis = .horizontal
			stackView.spacing = 15
			stackView.alignment = .center

			let circle = UIView()
			circle.backgroundColor = .black

			bag += circle.didLayoutSignal.onValue { circle.layer.cornerRadius = circle.frame.height / 2 }

			stackView.addArrangedSubview(circle)

			circle.snp.makeConstraints { make in make.height.width.equalTo(30) }

			let circleLabel = UILabel(
				value: String(index),
				style: TextStyle.brand(.body(color: .primary)).centerAligned
			)
			circle.addSubview(circleLabel)

			circleLabel.snp.makeConstraints { make in make.height.width.centerX.equalToSuperview()
				make.centerY.equalToSuperview().offset(3)
			}

			let textLabel = MultilineLabel(value: text, style: .brand(.headline(color: .secondary)))
			bag += stackView.addArranged(textLabel)

			return (stackView, bag)
		}
	}
}

extension OfferSwitcherBulletList: Viewable {
	func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
		let bag = DisposeBag()
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 15

		bag += stackView.didMoveToWindowSignal.take(first: 1)
			.onValue {
				stackView.snp.makeConstraints { make in make.width.equalToSuperview().multipliedBy(0.8)
				}
			}

		bag += client.fetch(query: GraphQL.OfferQuery()).valueSignal.compactMap { $0.insurance.previousInsurer }
			.onValueDisposePrevious { previousInsurer -> Disposable? in let innerBag = DisposeBag()

				innerBag += stackView.addArranged(BulletPoint(index: 1, text: L10n.signMobileBankId))

				if previousInsurer.switchable {
					innerBag += stackView.addArranged(
						BulletPoint(index: 2, text: L10n.offerSwitchColParagraphOneApp)
					)
				} else {
					innerBag += stackView.addArranged(
						BulletPoint(index: 2, text: L10n.offerNonSwitchableParagraphOneApp)
					)
				}

				innerBag += stackView.addArranged(
					BulletPoint(index: 3, text: L10n.offerSwitchColThreeParagraphApp)
				)

				return innerBag
			}

		return (stackView, bag)
	}
}
