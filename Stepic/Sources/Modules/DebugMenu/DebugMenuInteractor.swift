import Foundation
import PromiseKit

protocol DebugMenuInteractorProtocol {
    func doDebugDataLoad(request: DebugMenu.DebugDataLoad.Request)
    func doIAPFinishAllTransactions(request: DebugMenu.IAPFinishAllTransactions.Request)
    func doIAPUpdateCreateCoursePaymentDelay(request: DebugMenu.IAPUpdateCreateCoursePaymentDelay.Request)
}

final class DebugMenuInteractor: DebugMenuInteractorProtocol {
    private let presenter: DebugMenuPresenterProtocol
    private let provider: DebugMenuProviderProtocol

    private let iapService: IAPServiceProtocol

    init(
        presenter: DebugMenuPresenterProtocol,
        provider: DebugMenuProviderProtocol,
        iapService: IAPServiceProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.iapService = iapService
    }

    func doDebugDataLoad(request: DebugMenu.DebugDataLoad.Request) {
        self.fetchDebugData().done { data in
            self.presenter.presentDebugData(response: .init(data: data))
        }
    }

    func doIAPFinishAllTransactions(request: DebugMenu.IAPFinishAllTransactions.Request) {
        let result = self.iapService.finishAllPaymentTransactions()
        self.presenter.presentIAPFinishAllTransactionsResult(response: .init(finishedCount: result))
    }

    func doIAPUpdateCreateCoursePaymentDelay(request: DebugMenu.IAPUpdateCreateCoursePaymentDelay.Request) {
        self.provider.iapCreateCoursePaymentDelay = {
            guard let input = request.input,
                  !input.trimmed().isEmpty else {
                return nil
            }

            return Double(input)
        }()
        self.doDebugDataLoad(request: .init())
    }

    // MARK: Private API

    private func fetchDebugData() -> Guarantee<DebugMenu.DebugData> {
        self.provider.fetchFCMRegistrationToken().then { fcmTokenResult in
            let data = DebugMenu.DebugData(
                fcmRegistrationToken: fcmTokenResult,
                iapCreateCoursePaymentDelay: self.provider.iapCreateCoursePaymentDelay
            )
            return .value(data)
        }
    }
}
