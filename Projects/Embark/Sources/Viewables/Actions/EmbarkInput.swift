import Flow
import Form
import Foundation
import hCore
import hCoreUI
import SnapKit
import UIKit

struct EmbarkInput {
	let placeholder: ReadWriteSignal<String>
	let keyboardTypeSignal: ReadWriteSignal<UIKeyboardType?>
	let textContentTypeSignal: ReadWriteSignal<UITextContentType?>
	let autocapitalisationTypeSignal: ReadWriteSignal<UITextAutocapitalizationType>
	let returnKeyTypeSignal: ReadWriteSignal<UIReturnKeyType?>
	let enabledSignal: ReadWriteSignal<Bool>
	let shouldReturn = Delegate<String, Bool>()
	let insets: UIEdgeInsets
	let masking: Masking
	let shouldAutoFocus: Bool
	let fieldStyle: FieldStyle
	let shouldAutoSize: Bool
	let textFieldAlignment: NSTextAlignment

	init(
		placeholder: String,
		keyboardType: UIKeyboardType? = nil,
		textContentType: UITextContentType? = nil,
		returnKeyType: UIReturnKeyType? = nil,
		autocapitalisationType: UITextAutocapitalizationType,
		insets: UIEdgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 3),
		enabled: Bool = true,
		masking: Masking = Masking(type: .none),
		shouldAutoFocus: Bool = true,
		fieldStyle: FieldStyle = .embarkInputLarge,
		shouldAutoSize: Bool = false,
		textFieldAlignment: NSTextAlignment = .center
	) {
		self.placeholder = ReadWriteSignal(placeholder)
		self.insets = insets
		keyboardTypeSignal = ReadWriteSignal(keyboardType)
		textContentTypeSignal = ReadWriteSignal(textContentType)
		enabledSignal = ReadWriteSignal(enabled)
		returnKeyTypeSignal = ReadWriteSignal(returnKeyType)
		autocapitalisationTypeSignal = ReadWriteSignal(autocapitalisationType)
		self.masking = masking
		self.shouldAutoFocus = shouldAutoFocus
		self.fieldStyle = fieldStyle
		self.shouldAutoSize = shouldAutoSize
		self.textFieldAlignment = textFieldAlignment
	}
}

extension FieldStyle {
	static let embarkInputLarge = FieldStyle.default.restyled { (style: inout FieldStyle) in
		style.text = TextStyle.brand(.largeTitle(color: .primary)).centerAligned
		style.autocorrection = .no
		style.cursorColor = .brand(.primaryTintColor)
	}

	static let embarkInputSmall = FieldStyle.default.restyled { (style: inout FieldStyle) in
		style.text = TextStyle.brand(.headline(color: .primary)).centerAligned
		style.autocorrection = .no
		style.cursorColor = .brand(.primaryTintColor)
	}
}

extension EmbarkInput: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, ReadWriteSignal<String>) {
		let bag = DisposeBag()
		let view = UIControl()
		view.isUserInteractionEnabled = true

		let paddingView = UIStackView()
		paddingView.isUserInteractionEnabled = true
		paddingView.axis = .vertical
		paddingView.isLayoutMarginsRelativeArrangement = true
		paddingView.insetsLayoutMarginsFromSafeArea = false
		paddingView.layoutMargins = insets
		view.addSubview(paddingView)

		paddingView.snp.makeConstraints { make in make.trailing.leading.top.bottom.equalToSuperview() }

		let textField = UITextField(value: "", placeholder: "", style: fieldStyle)
		textField.backgroundColor = .clear
		textField.placeholder = placeholder.value
		textField.adjustsFontSizeToFitWidth = shouldAutoSize
		textField.textAlignment = textFieldAlignment

		bag += combineLatest(
			textContentTypeSignal.atOnce(),
			keyboardTypeSignal.atOnce(),
			autocapitalisationTypeSignal.atOnce(),
			returnKeyTypeSignal.atOnce()
		)
		.bindTo { textContentType, keyboardType, autocapitalisationType, returnKeyType in
			textField.textContentType = textContentType
			textField.keyboardType = keyboardType ?? .default
			textField.autocapitalizationType = autocapitalisationType
			textField.returnKeyType = returnKeyType ?? .default
			textField.reloadInputViews()
		}

		paddingView.addArrangedSubview(textField)

		let placeholderLabel = UILabel(value: placeholder.value, style: .brand(.largeTitle(color: .primary)))
		placeholderLabel.textAlignment = .center

		bag += textField.atOnce().onValue { value in placeholderLabel.alpha = value.isEmpty ? 1 : 0 }

		bag += textField.didMoveToWindowSignal.delay(by: 0.5).filter(predicate: { self.shouldAutoFocus })
			.onValue { _ in textField.becomeFirstResponder() }

		bag += view.signal(for: .touchDown).filter { !textField.isFirstResponder }
			.onValue { _ in textField.becomeFirstResponder() }

		bag += masking.applyMasking(textField)

		bag += textField.shouldReturn.set { value -> Bool in self.shouldReturn.call(value) ?? false }

		return (view, textField.providedSignal.hold(bag))
	}
}
