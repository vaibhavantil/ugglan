import Flow
import Form
import Foundation
import hCore
import UIKit

struct DiscountTerms {}

extension DiscountTerms: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let bag = DisposeBag()
		let view = UIControl()

		bag += view.signal(for: .touchUpInside).compactMap { URL(string: L10n.referralsReceiverTermsLink) }
			.onValue { url in UIApplication.shared.open(url, options: [:], completionHandler: nil) }

		let containerStackView = UIStackView()
		containerStackView.isLayoutMarginsRelativeArrangement = true
		containerStackView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
		containerStackView.isUserInteractionEnabled = false
		view.addSubview(containerStackView)

		containerStackView.snp.makeConstraints { make in make.top.bottom.leading.trailing.equalToSuperview() }

		let termsAndConditionsString = L10n.referralAddcouponTcLink
		let textStyle = TextStyle.brand(.footnote(color: .secondary)).centerAligned

		let termsLabelText = L10n.referralAddcouponTc(termsAndConditionsString)
			.attributedStringWithVariableStyles(
				[termsAndConditionsString: textStyle.colored(.brand(.primaryTintColor))],
				fallbackStyle: textStyle
			)

		let label = UILabel()
		label.isUserInteractionEnabled = false
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		label.attributedText = termsLabelText

		bag += label.didLayoutSignal.onValue { label.preferredMaxLayoutWidth = label.frame.size.width }

		label.setNeedsLayout()
		label.layoutIfNeeded()

		containerStackView.addArrangedSubview(label)

		return (view, bag)
	}
}
