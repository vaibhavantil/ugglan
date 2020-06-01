//
//  EmergencyView.swift
//  WatchAppExtension
//
//  Created by sam on 28.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

struct EmergencyView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("If you need emergency health care abroad you can contact Hedvig Global Assitance.").font(.hedvigBody)
                Button("Call") {
                    let phone = "0722155930"
                    if let telURL = URL(string: "tel:\(phone)") {
                        let wkExt = WKExtension.shared()
                        wkExt.openSystemURL(telURL)
                    }
                }.font(.hedvigBody)
            }.padding(10).frame(maxWidth: .infinity)
        }
    }
}

struct EmergencyView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyView()
    }
}
