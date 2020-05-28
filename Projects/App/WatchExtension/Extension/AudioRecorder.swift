//
//  AudioRecorder.swift
//  WatchAppExtension
//
//  Created by sam on 28.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import Apollo

struct AudioRecorder: View {
    let message: MessageFragment
    @EnvironmentObject var hostingController: HostingController.RootHostingController
    let onDone: () -> Void
    
    enum UploadingState {
        case notStarted
        case uploading
        case uploaded
    }
    
    @State var uploadingState = UploadingState.notStarted

    var body: some View {
        Group {
            if uploadingState == .uploaded {
                NavigationLink(destination: ClaimsCompleteView(), isActive: State(initialValue: true).projectedValue, label: {
                    Text("Next")
                })
            } else if uploadingState == .uploading {
                Text("Uploading your recording...")
            } else if uploadingState == .notStarted {
                Button("Start recording") {
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent("tmp.wav")
                    self.hostingController.hostingController.presentAudioRecorderController(withOutputURL: url, preset: .highQualityAudio, options: [:]) { (successful, error) in
                        
                        if successful {
                            self.uploadingState = .uploading
                            
                            Network.shared.apollo.upload(operation: SendChatAudioResponseMutation(globalID: self.message.globalId, file: "apple-watch.wav"), files: [try! .init(fieldName: "file", originalName: "apple-watch.wav", fileURL: url)]) { result in
                                self.uploadingState = .uploaded
                                self.onDone()
                            }
                            
                            Network.shared.apollo.perform(mutation: TriggerFreeTextChatMutation()) { result in
                                Network.shared.apollo.perform(mutation: SendChatTextResponseMutation(input: .init(globalId: self.message.globalId, body: .init(text: "A claim was submitted through Apple Watch."))))
                            }
                        }
                        
                    }
                }
            }
        }
        
    }
}
