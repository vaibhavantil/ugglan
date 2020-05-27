//
//  Network.swift
//  WatchAppExtension
//
//  Created by sam on 27.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Apollo

class Network {
  static let shared = Network()
  
  private lazy var networkTransport: HTTPNetworkTransport = {
    let transport = HTTPNetworkTransport(url: URL(string: "https://giraffe.hedvig.com/graphql")!)
    transport.delegate = self
    return transport
  }()
    
  private(set) lazy var apollo = ApolloClient(networkTransport: self.networkTransport)
}

extension Network: HTTPNetworkTransportPreflightDelegate {
  func networkTransport(_ networkTransport: HTTPNetworkTransport,
                          shouldSend request: URLRequest) -> Bool {
    return true
  }
  
  func networkTransport(_ networkTransport: HTTPNetworkTransport,
                        willSend request: inout URLRequest) {
    var headers = request.allHTTPHeaderFields ?? [String: String]()
    
    if let authorizationToken = UserDefaults.standard.string(forKey: "authorizationToken") {
        headers["Authorization"] = "Bearer \(authorizationToken)"
    }
      
    request.allHTTPHeaderFields = headers
  }
}
