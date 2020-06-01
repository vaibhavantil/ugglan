//
//  ContentView.swift
//  test WatchKit Extension
//
//  Created by sam on 27.5.20.
//  Copyright © 2020 hedvig. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var hasActiveContract: Bool? = nil

    func loadContracts() {
        Network.shared.apollo.fetch(query: ContractsQuery()) { response in
            switch response {
            case let .success(result):
                self.hasActiveContract = result.data?.contracts.count ?? 0 > 0
            case let .failure(error):
                print(error
                )
                self.hasActiveContract = false
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                if hasActiveContract == nil {
                    LoaderView().onAppear {
                        self.loadContracts()
                    }.transition(.hedvigTransition).font(.hedvigBody)
                }
                if hasActiveContract == false {
                    VStack {
                        Text("You need to have an active insurance to use the Apple Watch app! Open Hedvig on your phone to get one!").font(.hedvigBody)
                        Button("Reload") {
                            self.loadContracts()
                        }
                    }.transition(.hedvigTransition)
                }
                if hasActiveContract == true {
                    VStack {
                        Text("Hello Sam! How can we help today?").font(.hedvigBody)
                        NavigationLink(destination: ClaimsView(), label: {
                            Text("Submit claim").font(.hedvigBody)
                        })
                        NavigationLink(destination: EmergencyView(), label: {
                            Text("Emergency").font(.hedvigBody)
                        })
                    }.transition(.hedvigTransition)
                }
            }.padding(10).frame(maxWidth: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
