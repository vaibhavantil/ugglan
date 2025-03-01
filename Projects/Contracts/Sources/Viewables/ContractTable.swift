import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct ContractTable {
	@Inject var client: ApolloClient
	let presentingViewController: UIViewController
	let filter: ContractFilter
}

extension GraphQL.ContractsQuery.Data.Contract.CurrentAgreement {
	var type: ContractRow.ContractType {
		if let _ = asNorwegianHomeContentAgreement {
			return .norwegianHome
		} else if let _ = asNorwegianTravelAgreement {
			return .norwegianTravel
		} else if let _ = asSwedishApartmentAgreement {
			return .swedishApartment
		} else if let _ = asSwedishHouseAgreement {
			return .swedishHouse
		} else if let _ = asDanishHomeContentAgreement {
			return .danishHome
		} else if let _ = asDanishTravelAgreement {
			return .danishTravel
		} else if let _ = asDanishAccidentAgreement {
			return .danishAccident
		}

		fatalError("Unrecognised agreement provided")
	}
}

extension ContractTable: Viewable {
	func materialize(events _: ViewableEvents) -> (UITableView, Disposable) {
		let bag = DisposeBag()

		let sectionStyle = SectionStyle(
			rowInsets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15),
			itemSpacing: 0,
			minRowHeight: 10,
			background: .init(all: UIColor.clear.asImage()),
			selectedBackground: .init(all: UIColor.clear.asImage()),
			header: .none,
			footer: .none
		)

		let dynamicSectionStyle = DynamicSectionStyle { _ in sectionStyle }

		let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)

		let tableKit = TableKit<EmptySection, ContractRow>(style: style)
		bag += tableKit.view.addTableFooterView(ContractTableFooter(filter: filter))

		tableKit.view.backgroundColor = .brand(.primaryBackground())
		tableKit.view.alwaysBounceVertical = true

		let loadingIndicatorBag = DisposeBag()

		let loadingIndicator = LoadingIndicator(showAfter: 0.5, color: .brand(.primaryTintColor))
		loadingIndicatorBag += tableKit.view.add(loadingIndicator) { view in
			view.snp.makeConstraints { make in make.top.equalTo(0) }

			loadingIndicatorBag += tableKit.view.signal(for: \.contentSize)
				.onValue { size in
					view.snp.updateConstraints { make in
						make.top.equalTo(size.height - (view.frame.height / 2))
					}
				}
		}

		func watchContracts() {
			bag +=
				client.watch(
					query: GraphQL.ContractsQuery(
						locale: Localization.Locale.currentLocale.asGraphQLLocale()
					),
					cachePolicy: .fetchIgnoringCacheData
				)
				.compactMap { $0.contracts }
				.onValue { contracts in
					var contractsToShow = contracts.filter {
						switch self.filter {
						case .active: return $0.status.asTerminatedStatus == nil
						case .terminated: return $0.status.asTerminatedStatus != nil
						case .none: return false
						}
					}

					if contractsToShow.isEmpty, self.filter.emptyFilter.displaysTerminatedContracts {
						contractsToShow = contracts
					}

					let table = Table(
						rows: contractsToShow.map { contract -> ContractRow in
							ContractRow(
								contract: contract,
								displayName: contract.displayName,
								type: contract.currentAgreement.type
							)
						}
					)

					loadingIndicatorBag.dispose()

					tableKit.set(table)
				}
		}

		watchContracts()

		let refreshControl = UIRefreshControl()
		bag += client.refetchOnRefresh(
			query: GraphQL.ContractsQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()),
			refreshControl: refreshControl
		)

		tableKit.view.refreshControl = refreshControl

		return (tableKit.view, bag)
	}
}
