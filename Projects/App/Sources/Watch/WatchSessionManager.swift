//
//  WatchSessionManager.swift
//  Ugglan
//
//  Created by sam on 27.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import WatchConnectivity
 
class WatchSessionManager: NSObject, WCSessionDelegate {
    var messageQueue: [[String : Any]] = []
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            _ = messageQueue.drop { message -> Bool in
                try? updateApplicationContext(applicationContext: message)
                return true
            }
        }
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("state changed", session)
    }
    
    override init() {
        super.init()
    }
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    private var validSession: WCSession? {
        
        // paired - the user has to have their device paired to the watch
        // watchAppInstalled - the user must have your watch app installed
        
        // Note: if the device is paired, but your watch app is not installed
        // consider prompting the user to install it for a better experience
        
        if let session = session, session.isPaired, session.isWatchAppInstalled {
            return session
        }
        return nil
    }
    
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
    
    func updateApplicationContext(applicationContext: [String : Any]) throws {
        if session?.activationState != .activated {
            messageQueue.append(applicationContext)
            print("queing")
            return
        }
        
        if let session = validSession {
            do {
                try session.updateApplicationContext(applicationContext)
            } catch {
                throw error
            }
        }
    }
}
