//
//  WelcomePagerScreen.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-28.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit

struct WelcomePagerScreen {
    let title: String
    let paragraph: String
    let iconUrl: String
}

extension WelcomePagerScreen: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()

        let containerView = UIStackView()
        containerView.alpha = 1
        containerView.alignment = .center
        containerView.axis = .horizontal
        containerView.distribution = .fill
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let loadingIndicator = LoadingIndicator(showAfter: 0, color: .purple)
        let loadingIndicatorBag = DisposeBag()
        loadingIndicatorBag += containerView.addArranged(loadingIndicator)
        bag += loadingIndicatorBag

        let innerContainerView = UIStackView()
        innerContainerView.alpha = 0
        innerContainerView.alignment = .center
        innerContainerView.axis = .vertical
        innerContainerView.spacing = 8
        innerContainerView.isLayoutMarginsRelativeArrangement = true

        let icon = RemoteVectorIcon(iconUrl, threaded: true)

        containerView.addArrangedSubview(innerContainerView)

        innerContainerView.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
        }

        bag += icon.finishedLoadingSignal.onValue { _ in
            bag += Signal(after: 0).animated(style: AnimationStyle.easeOut(duration: 0.25), animations: {
                innerContainerView.alpha = 1
                loadingIndicatorBag.dispose()
            })
        }

        bag += innerContainerView.addArranged(icon) { iconView in
            iconView.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
            }
        }

        let spacing = Spacing(height: 30)
        bag += innerContainerView.addArranged(spacing)

        let titleLabel = MultilineLabel(styledText: StyledText(
            text: title,
            style: .standaloneLargeTitle
        ))

        bag += innerContainerView.addArranged(titleLabel) { titleLabelView in
            titleLabelView.textAlignment = .center

            titleLabelView.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(100)
            }

            bag += titleLabel.intrinsicContentSizeSignal.onValue { size in
                titleLabelView.snp.makeConstraints { make in
                    make.height.equalTo(size.height)
                }
            }
        }

        let bodyLabel = MultilineLabel(styledText: StyledText(
            text: paragraph,
            style: .bodyOffBlack
        ))

        bag += innerContainerView.addArranged(bodyLabel) { bodyLabelView in
            bodyLabelView.textAlignment = .center

            bodyLabelView.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(100)
            }

            bag += bodyLabel.intrinsicContentSizeSignal.onValue { size in
                bodyLabelView.snp.makeConstraints { make in
                    make.height.equalTo(size.height)
                }
            }
        }

        viewController.view = containerView

        bag += viewController.view.didLayoutSignal.onValue { _ in
            containerView.snp.makeConstraints { make in
                make.height.centerX.centerY.equalToSuperview()
                make.width.equalToSuperview().inset(20)
            }
        }

        return (viewController, bag)
    }
}
