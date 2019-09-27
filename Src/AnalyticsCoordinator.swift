//
//  AnalyticsCoordinator.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-27.
//

import Foundation
import Firebase
import Apollo
import Flow

struct AnalyticsCoordinator {
    static func logEcommercePurchase(client: ApolloClient = ApolloContainer.shared.client) {
        let bag = DisposeBag()
        bag += client.fetch(query: InsurancePriceQuery())
        .valueSignal
        .compactMap { $0.data?.insurance.cost?.fragments.costFragment.monthlyGross }
        .onValue { monthlyGross in
            bag.dispose()
            Analytics.logEvent("ecommerce_purchase", parameters: [
                "transaction_id": UUID().uuidString,
                "value": Double(monthlyGross.amount) ?? 0,
                "currency": monthlyGross.currency
            ])
        }
    }
}
