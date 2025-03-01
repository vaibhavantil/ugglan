import Flow
import Form
import Foundation
import hCore
import UIKit

public struct CloseButton {
	private let onTapReadWriteSignal = ReadWriteSignal<Void>(())
	public let onTapSignal: Signal<Void>

	public var barButtonItem: UIBarButtonItem { UIBarButtonItem(viewable: self) }

	public init() { onTapSignal = onTapReadWriteSignal.plain() }
}

extension CloseButton: Viewable {
	public func materialize(events _: ViewableEvents) -> (UIControl, Disposable) {
		let bag = DisposeBag()
		let button = UIControl()

		button.snp.makeConstraints { make in make.width.height.equalTo(30) }

		bag += button.signal(for: .touchDown).map { 0.5 }
			.bindTo(animate: AnimationStyle.easeOut(duration: 0.25), button, \.alpha)

		let touchUpInside = button.signal(for: .touchUpInside)

		bag += touchUpInside.feedback(type: .impactLight)

		bag += touchUpInside.map {}.toVoid().bindTo(onTapReadWriteSignal)

		bag += merge(
			button.signal(for: .touchUpInside),
			button.signal(for: .touchUpOutside),
			button.signal(for: .touchCancel)
		)
		.map { 1 }.bindTo(animate: AnimationStyle.easeOut(duration: 0.25), button, \.alpha)

		let icon = Icon(icon: hCoreUIAssets.close.image, iconWidth: 15)
		icon.image.tintColor = .brand(.primaryText())
		button.addSubview(icon)

		icon.snp.makeConstraints { make in make.width.height.centerX.centerY.equalToSuperview() }

		return (button, bag)
	}
}
