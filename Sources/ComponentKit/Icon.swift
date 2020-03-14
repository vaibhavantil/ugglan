//
//  Icon.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-11.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import UIKit

public class Icon: UIView {
    public let image = UIImageView()
    public var icon: UIImage {
        didSet {
            setup()
        }
    }

    public var iconWidth: CGFloat {
        didSet {
            image.snp.remakeConstraints { make in
                make.width.equalTo(iconWidth)
                make.height.equalToSuperview()
                make.center.equalToSuperview()
            }
        }
    }

    public override var tintColor: UIColor! {
        didSet(newValue) {
            image.tintColor = newValue
        }
    }

    public init(frame: CGRect = .zero, icon: UIImage, iconWidth: CGFloat) {
        self.icon = icon
        self.iconWidth = iconWidth
        super.init(frame: frame)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: iconWidth, height: iconWidth)
    }

    func setup() {
        image.isUserInteractionEnabled = false
        isUserInteractionEnabled = false

        image.image = icon
        addSubview(image)

        image.contentMode = .scaleAspectFit

        image.snp.makeConstraints { make in
            make.width.equalTo(iconWidth)
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}
