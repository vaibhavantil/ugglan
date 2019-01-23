//
//  CircleLabel.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-04.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit

struct CircleLabel {
    let labelText: DynamicString
    let backgroundColor: UIColor?
    let textColor: UIColor?

    init(labelText: DynamicString, backgroundColor: UIColor? = .lightGray, textColor: UIColor? = .white) {
        self.labelText = labelText
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
}

extension CircleLabel: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        let bag = DisposeBag()

        let label = UILabel()
        bag += label.setDynamicText(labelText)

        label.backgroundColor = backgroundColor
        label.clipsToBounds = true
        label.textAlignment = .center
        label.font = HedvigFonts.circularStdBold?.withSize(30)
        label.textColor = textColor
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true

        view.addSubview(label)

        bag += label.didLayoutSignal.onValue { _ in
            label.layer.cornerRadius = label.frame.height * 0.5
        }

        label.snp.makeConstraints { make in
            make.width.equalTo(label.snp.height)
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }

        view.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }

        return (view, bag)
    }
}
