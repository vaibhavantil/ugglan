//
//  AudioRecorder.swift
//  WatchAppExtension
//
//  Created by sam on 28.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Apollo
import Foundation
import SwiftUI

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
                }).transition(.hedvigTransition)
            } else if uploadingState == .uploading {
                LoaderView().transition(.hedvigTransition)
            } else if uploadingState == .notStarted {
                Button("Start") {
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent("tmp.wav")
                    self.hostingController.hostingController.presentAudioRecorderController(withOutputURL: url, preset: .highQualityAudio, options: [:]) { successful, _ in

                        if successful {
                            self.uploadingState = .uploading

                            Network.shared.apollo.upload(operation: SendChatAudioResponseMutation(globalID: self.message.globalId, file: "apple-watch.wav"), files: [try! .init(fieldName: "file", originalName: "apple-watch.wav", fileURL: url)]) { _ in
                                self.uploadingState = .uploaded
                                self.onDone()

                                Network.shared.apollo.perform(mutation: TriggerFreeTextChatMutation()) { _ in
                                    Network.shared.apollo.perform(mutation: SendChatTextResponseMutation(input: .init(globalId: self.message.globalId, body: .init(text: "A claim was submitted through Apple Watch."))))
                                }
                            }
                        }
                    }
                }.transition(.hedvigTransition)
            }
        }
    }
}
