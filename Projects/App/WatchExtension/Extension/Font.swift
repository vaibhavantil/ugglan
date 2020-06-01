//
//  Font.swift
//  WatchAppExtension
//
//  Created by sam on 29.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

extension Font {
    static var hedvigBody: Font {
        .custom("FavoritStd-Book", size: UIFont.preferredFont(forTextStyle: .body).pointSize)
    }

    static var hedvigFootnote: Font {
        .custom("FavoritStd-Book", size: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
    }
}
