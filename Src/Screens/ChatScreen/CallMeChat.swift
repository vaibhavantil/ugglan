//
//  CallMeChat.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-16.
//

import Apollo
import Flow
import Foundation
import Presentation
import UIKit

struct CallMeChat {
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension CallMeChat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let chat = Chat(shouldSubscribe: false)
        let (viewController, future) = chat.materialize()

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }

        bag += client.perform(mutation: TriggerCallMeChatMutation()).onValue({ _ in
            chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData)
        })

        return (viewController, Future { completion in
            bag += future.onResult { result in
                completion(result)
            }

            return Disposer {
                future.cancel()
                bag.dispose()
            }
        })
    }
}
