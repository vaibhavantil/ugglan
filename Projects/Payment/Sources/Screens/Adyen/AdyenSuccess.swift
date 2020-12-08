import Flow
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

struct AdyenSuccess {}

extension AdyenSuccess: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let continueButton = Button(
            title: L10n.PayInConfirmation.continueButton,
            type: .standard(backgroundColor: .brand(.secondaryButtonBackgroundColor), textColor: .brand(.secondaryButtonTextColor))
        )

        let continueAction = ImageTextAction<Void>(
            image: .init(image: hCoreUIAssets.circularCheckmark.image, size: CGSize(width: 32, height: 32), contentMode: .scaleAspectFit),
            title: L10n.PayInConfirmation.headline,
            body: "",
            actions: [
                ((), continueButton),
            ],
            showLogo: false
        )

        let (viewController, signal) = PresentableViewable(viewable: continueAction) { viewController in
            viewController.navigationItem.hidesBackButton = true
        }.materialize()

        return (viewController, Future { completion in
            let bag = DisposeBag()

            bag += signal.onValue {
                completion(.success)
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
