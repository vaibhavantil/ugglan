//
//  WatchSessionManager.swift
//  WatchAppExtension
//
//  Created by sam on 27.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation

import WatchConnectivity
 
class WatchSessionManager: NSObject, WCSessionDelegate {
    static let sharedManager = WatchSessionManager()
    
    override init() {
        super.init()
    }
    
    private let session: WCSession = WCSession.default
    
    func startSession() {
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let authorizationToken = applicationContext["authorizationToken"] as? String {
            UserDefaults.standard.set(authorizationToken, forKey: "authorizationToken")
        }
    }
}
