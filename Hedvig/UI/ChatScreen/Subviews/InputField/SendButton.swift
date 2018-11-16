//
//  SendButton.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-11.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Tempura

class SendButton: UIButton, View {
    let arrowUpIcon = Icon(frame: .zero, iconName: "ArrowUp", iconWidth: 10)
    var activated: Bool {
        didSet {
            update()
        }
    }

    var onSend: () -> Void

    init(frame: CGRect, onSend: @escaping () -> Void) {
        self.onSend = onSend
        activated = true
        super.init(frame: frame)
        setup()
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        addSubview(arrowUpIcon)
        addTarget(self, action: #selector(onTap), for: .touchDown)
        addTarget(self, action: #selector(onTapRelease), for: .touchUpInside)
    }

    @objc func onTap() {
        UIView.animate(withDuration: 0.25) {
            if self.activated {
                self.backgroundColor = HedvigColors.purple.darkened(amount: 0.25)
            } else {
                self.backgroundColor = HedvigColors.darkGray.darkened(amount: 0.25)
            }
        }
    }

    @objc func onTapRelease() {
        if activated {
            onSend()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }

        UIView.animate(withDuration: 0.25) {
            if self.activated {
                self.backgroundColor = HedvigColors.purple
            } else {
                self.backgroundColor = HedvigColors.darkGray
            }
        }
    }

    func style() {
        backgroundColor = HedvigColors.purple
        layer.cornerRadius = 15
    }

    func update() {
        UIView.animate(withDuration: 0.25) {
            if self.activated {
                self.backgroundColor = HedvigColors.purple
            } else {
                self.backgroundColor = HedvigColors.darkGray
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.width(30)
        pin.height(30)
        arrowUpIcon.pin.center()
    }
}
