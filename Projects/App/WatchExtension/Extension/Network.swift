//
//  Network.swift
//  WatchAppExtension
//
//  Created by sam on 27.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Apollo
import ApolloWebSocket

class Network {
  static let shared = Network()
  
  private lazy var httpNetworkTransport: HTTPNetworkTransport = {
    let transport = HTTPNetworkTransport(url: URL(string: "https://graphql.dev.hedvigit.com/graphql")!)
    transport.delegate = self
    return transport
  }()
    
private lazy var webSocketTransport: WebSocketTransport = {
  let url = URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!
  let request = URLRequest(url: url)
    var connectingPayload: [String: String] = [:]
    
    if let authorizationToken = UserDefaults.standard.string(forKey: "authorizationToken") {
        connectingPayload["Authorization"] = authorizationToken
    }
    
  return WebSocketTransport(request: request, connectingPayload: connectingPayload)
}()
    
    private lazy var splitNetworkTransport = SplitNetworkTransport(
      httpNetworkTransport: self.httpNetworkTransport,
      webSocketNetworkTransport: self.webSocketTransport
    )
    
    private(set) lazy var apollo = ApolloClient(networkTransport: self.splitNetworkTransport)
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
        headers["Authorization"] = authorizationToken
        headers["Accept-Language"] = "en_SE"
    }
      
    request.allHTTPHeaderFields = headers
  }
}
