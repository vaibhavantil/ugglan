//
//  PerilDetail.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-18.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCoreUI

struct PerilDetail {
    let title: String
    let description: String
    let icon: RemoteVectorIcon
}

extension PerilDetail: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let form = FormView()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 24)

        form.append(stackView)
        stackView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }

        let icon = self.icon

        bag += stackView.addArranged(icon) { iconView in
            iconView.snp.makeConstraints { make in
                make.height.width.equalTo(130)
            }
        }

        bag += stackView.addArranged(Spacing(height: 80))

        stackView.addArrangedSubview(UILabel(value: title, style: .headlineLargeLargeLeft))

        bag += stackView.addArranged(Spacing(height: 15))

        bag += stackView.addArranged(MultilineLabel(value: description, style: .bodySmallSmallCenter))

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
