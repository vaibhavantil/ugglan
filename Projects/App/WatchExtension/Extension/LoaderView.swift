//
//  Loader.swift
//  WatchAppExtension
//
//  Created by sam on 29.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

struct LoaderBall: View {
    var body: some View {
        Rectangle()
            .background(Color.white)
            .frame(width: 10, height: 10, alignment: .center)
            .cornerRadius(5)
    }
}

struct LoaderView: View {
    var foreverAnimation: Animation {
        Animation.spring(response: 0.5, dampingFraction: 1, blendDuration: 0)
            .repeatForever()
    }

    @State var size: CGFloat = 0

    var body: some View {
        HStack {
            LoaderBall()
                .animation(self.foreverAnimation)
                .offset(x: 0, y: self.size).onAppear {
                    self.size = 8
                }
            LoaderBall()
                .animation(self.foreverAnimation.delay(0.25))
                .offset(x: 0, y: self.size)
            LoaderBall()
                .animation(self.foreverAnimation.delay(0.35))
                .offset(x: 0, y: self.size)
        }
    }
}
