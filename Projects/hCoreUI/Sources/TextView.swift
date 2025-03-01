import Flow
import Form
import Foundation
import hCore
import UIKit

public struct TextView {
	public let placeholder: ReadWriteSignal<String>
	public let keyboardTypeSignal: ReadWriteSignal<UIKeyboardType?>
	public let textContentTypeSignal: ReadWriteSignal<UITextContentType?>
	public let enabledSignal: ReadWriteSignal<Bool>
	public let shouldReturn = Delegate<(String, UITextField), Bool>()
	public let insets: UIEdgeInsets

	private let didBeginEditingCallbacker: Callbacker<Void> = Callbacker()

	public var didBeginEditingSignal: Signal<Void> { didBeginEditingCallbacker.providedSignal }

	public init(
		placeholder: String,
		keyboardTypeSignal: UIKeyboardType? = nil,
		textContentType: UITextContentType? = nil,
		insets: UIEdgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 3),
		enabled: Bool = true
	) {
		self.placeholder = ReadWriteSignal(placeholder)
		self.insets = insets
		self.keyboardTypeSignal = ReadWriteSignal(keyboardTypeSignal)
		textContentTypeSignal = ReadWriteSignal(textContentType)
		enabledSignal = ReadWriteSignal(enabled)
	}
}

extension UITextView: SignalProvider {
	public var providedSignal: ReadWriteSignal<String> {
		Signal { callback in let bag = DisposeBag()

			bag += NotificationCenter.default
				.signal(forName: UITextView.textDidChangeNotification, object: self)
				.onValue { _ in callback(self.text) }

			return bag
		}
		.readable(getValue: { () -> String in self.text })
		.writable(setValue: { newValue in self.text = newValue })
	}

	public var didBeginEditingSignal: Signal<Void> {
		NotificationCenter.default.signal(forName: UITextView.textDidBeginEditingNotification, object: self)
			.toVoid()
	}
}

extension TextView: Viewable {
	public func materialize(events _: ViewableEvents) -> (UIView, ReadWriteSignal<String>) {
		let bag = DisposeBag()
		let view = UIControl()
		view.backgroundColor = .brand(.primaryBackground())
		view.isUserInteractionEnabled = true
		view.layer.cornerRadius = 6
		view.layer.borderWidth = 1

		bag += view.applyBorderColor { _ in .brand(.primaryBorderColor) }

		let paddingView = UIStackView()
		paddingView.isUserInteractionEnabled = true
		paddingView.axis = .vertical
		paddingView.isLayoutMarginsRelativeArrangement = true
		paddingView.layoutMargins = insets
		view.addSubview(paddingView)

		paddingView.snp.makeConstraints { make in make.trailing.leading.top.bottom.equalToSuperview() }

		let textView = UITextView()
		textView.tintColor = .brand(.primaryTintColor)
		textView.font = Fonts.favoritStdBook.withSize(14)
		textView.backgroundColor = .clear

		bag += combineLatest(textContentTypeSignal.atOnce(), keyboardTypeSignal.atOnce())
			.bindTo { (textContentType: UITextContentType?, keyboardType: UIKeyboardType?) in
				textView.textContentType = textContentType
				textView.keyboardType = keyboardType ?? .default
				textView.reloadInputViews()
			}

		textView.snp.remakeConstraints { make in make.height.equalTo(34) }

		view.snp.makeConstraints { make in make.height.equalTo(40) }

		bag += textView.didBeginEditingSignal.onValue { _ in self.didBeginEditingCallbacker.callAll() }

		let contentHeightSignal = ReadWriteSignal<CGFloat>(0)

		bag += textView.contentSizeSignal.animated(style: SpringAnimationStyle.lightBounce()) { size in
			let cappedContentHeight = min(120, size.height)

			textView.snp.remakeConstraints { make in make.height.equalTo(cappedContentHeight) }

			view.snp.remakeConstraints { make in make.height.equalTo(cappedContentHeight + 6) }

			textView.layoutIfNeeded()
			textView.layoutSuperviewsIfNeeded()

			if textView.contentSize.height != contentHeightSignal.value {
				textView.scrollToBottom(animated: false)
			}

			contentHeightSignal.value = size.height
		}

		paddingView.addArrangedSubview(textView)

		let placeholderLabel = UILabel(value: placeholder.value, style: .brand(.footnote(color: .secondary)))
		paddingView.addSubview(placeholderLabel)

		bag += placeholder.map { Optional($0) }
			.bindTo(
				transition: placeholderLabel,
				style: .crossDissolve(duration: 0.25),
				placeholderLabel,
				\.text
			)

		placeholderLabel.snp.makeConstraints { make in make.left.equalTo(paddingView.layoutMargins.left + 5)
			make.centerY.equalToSuperview()
			make.width.equalToSuperview()
		}

		bag += textView.atOnce().onValue { value in placeholderLabel.alpha = value.isEmpty ? 1 : 0 }

		bag += view.signal(for: .touchDown).filter { !textView.isFirstResponder }
			.onValue { _ in textView.becomeFirstResponder() }

		return (
			view,
			Signal { callback in bag += textView.providedSignal.onValue { value in callback(value) }

				return bag
			}
			.readable(getValue: { textView.value })
			.writable(setValue: { newValue in placeholderLabel.alpha = newValue.isEmpty ? 1 : 0
				textView.value = newValue
			})
		)
	}
}
