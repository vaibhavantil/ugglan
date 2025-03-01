import Flow
import Foundation
import hCore
import hCoreUI
import UIKit

struct SendButton {}

extension SendButton: Viewable {
	func materialize(events _: ViewableEvents) -> (UIControl, Signal<Void>) {
		let bag = DisposeBag()
		let control = UIControl()
		control.backgroundColor = .clear
		control.layer.cornerRadius = 8

		control.snp.makeConstraints { make in make.width.height.equalTo(30) }

		let icon = Icon(icon: Asset.sendChat.image, iconWidth: 15)
		control.addSubview(icon)

		icon.snp.makeConstraints { make in make.width.height.equalTo(15)
			make.center.equalToSuperview()
		}

		let touchUpInside = control.signal(for: .touchUpInside)

		bag += touchUpInside.feedback(type: .impactLight)

		bag += control.signal(for: .touchDown)
			.animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
				control.backgroundColor = UIColor.brand(.secondaryBackground()).darkened(amount: 0.1)
			}

		bag += merge(touchUpInside, control.signal(for: .touchCancel), control.signal(for: .touchUpOutside))
			.animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
				control.backgroundColor = UIColor.clear
			}

		return (
			control,
			Signal { callback in bag += touchUpInside.onValue(callback)
				return bag
			}
		)
	}
}
