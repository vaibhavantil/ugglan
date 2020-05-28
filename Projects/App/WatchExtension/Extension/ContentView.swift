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
            case .success(let result):
                self.hasActiveContract = result.data?.contracts.count ?? 0 > 0
            case .failure(let error):
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
                    Text("Loading!").onAppear {
                        self.loadContracts()
                    }
                }
                 if hasActiveContract == false {
                    Text("You need to have an active insurance to use the Apple Watch app! Open Hedvig on your phone to get one!")
                    Button("Reload") {
                        self.loadContracts()
                    }
                 }
                 if hasActiveContract == true {
                     Text("Hello Sam! How can we help today?")
                     NavigationLink(destination: ClaimsView(), label: {
                         Text("Submit claim")
                     })
                     NavigationLink(destination: EmergencyView(), label: {
                         Text("Emergency Abroad")
                     }).listRowBackground(Color.red)
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
