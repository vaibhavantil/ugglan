//
//  UIView+CornerRadius.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-01-22.
//

import Foundation
import UIKit
import Flow

extension UIView {
    func applyCornerRadius(getCornerRadius: @escaping (_ traitCollection: UITraitCollection) -> CGFloat) -> Disposable {
        
        let bag = DisposeBag()
        
        bag += didLayoutSignal.onValue { _ in
            self.layer.cornerRadius = getCornerRadius(self.traitCollection)
        }
        
        bag += traitCollectionSignal.onValue { trait in
            self.layer.cornerRadius = getCornerRadius(trait)
        }
        
        return bag
    }
}
