import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct EmbarkSelectActionOption {
    let data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction.SelectActionDatum.Option
}

extension EmbarkSelectActionOption: Viewable {
    func materialize(events _: ViewableEvents) -> (UIControl, Signal<ActionResponseData>) {
        let bag = DisposeBag()
        let control = UIControl()
        control.backgroundColor = .brand(.secondaryBackground())
        control.layer.cornerRadius = 8
        bag += control.applyShadow { _ -> UIView.ShadowProperties in
            .embark
        }

        let stackView = UIStackView()
        stackView.isUserInteractionEnabled = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.layoutMargins = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.insetsLayoutMarginsFromSafeArea = false
        control.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        return (control, Signal { callback in
            
            let valueLabel = MultilineLabel(
                value: data.link.fragments.embarkLinkFragment.label,
                style: TextStyle.brand(.headline(color: .primary)).centerAligned
            )
            
            bag += stackView.addArranged(valueLabel)

            bag += control.signal(for: .touchDown).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                control.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }

            bag += control.delayedTouchCancel(delay: 0.1).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                control.transform = CGAffineTransform.identity
            }

            bag += control.signal(for: .touchUpInside).feedback(type: .impactLight)

            bag += control.signal(for: .touchUpInside).onValue { _ in
                let textValue = self.data.link.fragments.embarkLinkFragment.label
                callback(ActionResponseData(
                    keys: self.data.keys,
                    values: self.data.values,
                    textValue: textValue
                ))
            }

            return bag
        })
    }
}
