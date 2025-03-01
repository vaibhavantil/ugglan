import Apollo
import Foundation
import hCore
import hGraphQL
import SwiftUI

@available(iOS 13, *) struct ExchangeToken: View {
	let onToken: (_ token: String, _ locale: Localization.Locale) -> Void

	init(onToken: @escaping (_ token: String, _ locale: Localization.Locale) -> Void) { self.onToken = onToken }

	@State var paymentUrl: String = ""
	@Inject var client: ApolloClient

	@State private var selectedLocale = Localization.Locale.currentLocale

	let locales = Localization.Locale.allCases

	var body: some View {
		NavigationView {
			Form {
				TextField("Payment url", text: $paymentUrl)
				Section {
					Picker("Locale", selection: $selectedLocale) {
						ForEach(locales, id: \.self) { Text($0.code) }
					}
					.pickerStyle(WheelPickerStyle())
				}
				SwiftUI.Button("Exchange") {
					let afterHashbang = paymentUrl.split(separator: "#").last
					let exchangeToken =
						afterHashbang?.replacingOccurrences(of: "exchange-token=", with: "")
						?? ""

					client.perform(
						mutation: GraphQL.ExchangeTokenMutation(
							exchangeToken: exchangeToken.removingPercentEncoding ?? ""
						)
					)
					.onValue { response in
						guard
							let token = response.exchangeToken
								.asExchangeTokenSuccessResponse?
								.token
						else { return }
						onToken(token, selectedLocale)
					}
				}
			}
		}
	}
}
