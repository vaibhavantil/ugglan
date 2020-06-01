//
//  ClaimsView.swift
//  WatchAppExtension
//
//  Created by sam on 27.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Apollo
import AVFoundation
import Foundation
import SwiftUI
import UIKit

extension Color {
    static let messageFromHedvigColor = Color(UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.00))
    static let messageFromHedvigTextColor = Color.white
    static let messageFromMyselfColor = Color.white
    static let messageFromMyselfTextColor = Color.black
}

extension MessageFragment {
    var textBody: String {
        print(body)
        if let body = self.body.asMessageBodyText {
            return body.text
        } else if let body = self.body.asMessageBodyParagraph {
            return body.text
        } else if let body = self.body.asMessageBodyNumber {
            return body.text
        } else if let body = self.body.asMessageBodyAudio {
            return body.text
        } else if let body = self.body.asMessageBodySingleSelect {
            return body.text
        }

        return ""
    }

    var placeholder: String {
        if let body = self.body.asMessageBodyNumber {
            return body.placeholder ?? "Enter text"
        }

        return ""
    }
}

extension MessageFragment: Equatable {
    public static func == (lhs: MessageFragment, rhs: MessageFragment) -> Bool {
        lhs.globalId == rhs.globalId
    }
}

struct LastArrayItem<T, BodyView: View>: View {
    var array: [T]
    var getBody: (_ firstItem: T) -> BodyView

    var body: some View {
        Group {
            if array.last != nil {
                getBody(array.last!).transition(.hedvigTransition)
            }

            if array.last == nil {
                LoaderView().transition(.hedvigTransition)
            }
        }
    }
}

struct OptionalView<T, BodyView: View>: View {
    var value: T?
    var getBody: (_ value: T) -> BodyView

    var body: some View {
        Group {
            if value != nil {
                getBody(value!)
            }
        }
    }
}

struct SingleSelect: View {
    let message: MessageFragment
    @State var loading: Bool = false
    var onDone: () -> Void

    var body: some View {
        Group {
            OptionalView(value: message.body.asMessageBodySingleSelect) { singleSelect in
                ForEach(singleSelect.choices?.compactMap { $0 } ?? [], id: \.asMessageBodyChoicesSelection?.text) { choice in
                    Button(choice.asMessageBodyChoicesSelection?.text ?? "") {
                        self.onDone()
                        Network.shared.apollo.perform(mutation: SendChatSingleSelectResponseMutation(input: .init(globalId: self.message.globalId, body: .init(selectedValue: choice.asMessageBodyChoicesSelection?.value ?? ""))))
                    }.font(.hedvigFootnote).transition(.hedvigTransition)
                }
            }
        }
    }
}

extension AnyTransition {
    static var hedvigTransition: AnyTransition {
        AnyTransition.scale.combined(with: AnyTransition.opacity.animation(.easeInOut(duration: 0.25))).animation(.easeInOut(duration: 0.25))
    }
}

struct MessageDetail: View {
    var message: MessageFragment
    let unreadMessages: [MessageFragment]

    @State var response: String = ""

    var onReadMessage: () -> Void

    var body: some View {
        Group {
            HStack {
                VStack {
                    Text(message.textBody)
                        .font(.footnote)
                        .foregroundColor(message.header.fromMyself ? Color.messageFromMyselfTextColor : Color.messageFromHedvigTextColor)
                        .padding(10)
                        .font(.hedvigFootnote)
                        .frame(maxWidth: .infinity)
                }
                .background(message.header.fromMyself ? Color.messageFromMyselfColor : Color.messageFromHedvigColor)
                .cornerRadius(6)
            }.id(message.globalId).transition(.hedvigTransition)
            if self.unreadMessages.count > 1 {
                Button(action: {
                    self.onReadMessage()
                }, label: {
                    Text("Next").font(.hedvigFootnote)
                 }).transition(.hedvigTransition)
            } else if message.body.asMessageBodySingleSelect != nil {
                SingleSelect(message: message) {
                    self.onReadMessage()
                }
            } else if message.body.asMessageBodyAudio != nil {
                AudioRecorder(message: message) {
                    self.onReadMessage()
                }
            } else if message.body.asMessageBodyParagraph == nil {
                Group {
                    TextField(message.placeholder, text: self.$response)
                    Button(action: {
                        Network.shared.apollo.perform(mutation: SendChatTextResponseMutation(input: .init(globalId: self.message.globalId, body: .init(text: self.response))))
                    }, label: {
                        Text("Send").font(.hedvigFootnote)
                     })
                }
            }
        }.transition(.scale)
    }
}

struct ClaimsView: View {
    @State var readMessages: [MessageFragment] = []
    var unreadMessages: [MessageFragment] {
        messages.filter { message -> Bool in
            !readMessages.contains { readMessage -> Bool in
                message.globalId == readMessage.globalId
            }
        }.filter { message -> Bool in
            message.id.contains("claims") && !message.header.fromMyself
        }
    }

    @State var messages: [MessageFragment] = []
    @State var timer: Timer? = nil
    @State var isInitialised = false

    var body: some View {
        ScrollView {
            VStack {
                LastArrayItem(array: unreadMessages) { message in
                    MessageDetail(message: message, unreadMessages: self.unreadMessages) {
                        if let lastMessage = self.unreadMessages.last {
                            self.readMessages.append(lastMessage)
                        }
                    }
                }
            }.frame(maxWidth: .infinity).padding([.leading, .trailing], 10)
        }.onAppear {
            let startTime = Date()

            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                Network.shared.apollo.fetch(query: ChatMessagesQuery(), cachePolicy: .fetchIgnoringCacheCompletely) { response in
                    switch response {
                    case let .success(result):
                        if result.errors != nil {
                            return
                        }

                        if let messages = result.data?.messages.compactMap({ $0 }).filter({ message -> Bool in
                            let timeStampInt = Double(message.header.timeStamp) ?? 0
                            return startTime.timeIntervalSince1970 < TimeInterval(timeStampInt / 1000)
                                   }).map({ $0.fragments.messageFragment }) {
                            if self.messages != messages {
                                self.messages = messages
                            }
                        }
                    case .failure:
                        break
                    }
                }
            }

            guard !self.isInitialised else {
                return
            }

            self.isInitialised = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Network.shared.apollo.perform(mutation: TriggerClaimChatMutation()) { response in
                    switch response {
                    case let .success(result):
                        print(result)
                    case .failure:
                        break
                    }
                }
            }
        }.onDisappear {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}
