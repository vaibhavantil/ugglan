//
//  ClaimsCompleteView.swift
//  WatchAppExtension
//
//  Created by sam on 28.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

struct ClaimsCompleteView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("We have now received your claim, we will be in touch via phone shortly!")
            }.padding(10).frame(maxWidth: .infinity)
        }
    }
}
