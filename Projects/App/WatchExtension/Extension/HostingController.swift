//
//  HostingController.swift
//  test WatchKit Extension
//
//  Created by sam on 27.5.20.
//  Copyright © 2020 hedvig. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
    class RootHostingController: ObservableObject {
        let hostingController: WKHostingController<AnyView>
        
        init(hostingController: WKHostingController<AnyView>) {
            self.hostingController = hostingController
        }
    }
    
    override var body: AnyView {
        AnyView(Group {
             ContentView().environmentObject(RootHostingController(hostingController: self))
        })
    }
}
