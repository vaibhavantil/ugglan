import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL

struct BankDetailsSection {
    @Inject var client: ApolloClient
    let urlScheme: String
}

extension BankDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: L10n.myPaymentBankRowLabel,
            footer: nil
        )
        let row = KeyValueRow()
        row.valueStyleSignal.value = .brand(.headline(color: .quartenary))

        bag += section.append(row)

        let dataSignal = client.watch(query: GraphQL.MyPaymentQuery())
        let noBankAccountSignal = dataSignal.filter {
            $0.bankAccount == nil
        }

        bag += noBankAccountSignal.map {
            _ in L10n.myPaymentNotConnected
        }.bindTo(row.keySignal)

        bag += dataSignal.compactMap {
            $0.bankAccount?.bankName
        }.bindTo(row.keySignal)

        bag += dataSignal.compactMap {
            $0.bankAccount?.descriptor
        }.bindTo(row.valueSignal)

        let myPaymentQuerySignal = client.watch(query: GraphQL.MyPaymentQuery(), cachePolicy: .returnCacheDataAndFetch)

        bag += myPaymentQuerySignal.onValueDisposePrevious { data in
            let innerBag = bag.innerBag()

            if data.payinMethodStatus != .pending {
                let hasAlreadyConnected = data.payinMethodStatus != .needsSetup
                let buttonText = hasAlreadyConnected ? L10n.myPaymentDirectDebitReplaceButton : L10n.myPaymentDirectDebitButton

                let paymentSetupRow = RowView(
                    title: buttonText,
                    style: .brand(.headline(color: .link))
                )

                bag += section.append(paymentSetupRow).compactMap { section.viewController }.onValue { viewController in
                    let setup = PaymentSetup(
                        setupType: hasAlreadyConnected ? .replacement : .initial,
                        urlScheme: self.urlScheme
                    )
                    viewController.present(setup, style: .modally(), options: [.defaults, .allowSwipeDismissAlways])
                }

                bag += {
                    section.remove(paymentSetupRow)
                }
            }

            return innerBag
        }

        return (section, bag)
    }
}
