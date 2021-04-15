import Foundation
import PromiseKit

protocol DebugMenuInteractorProtocol {
    func doDebugDataLoad(request: DebugMenu.DebugDataLoad.Request)
}

final class DebugMenuInteractor: DebugMenuInteractorProtocol {
    private let presenter: DebugMenuPresenterProtocol
    private let provider: DebugMenuProviderProtocol

    init(
        presenter: DebugMenuPresenterProtocol,
        provider: DebugMenuProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doDebugDataLoad(request: DebugMenu.DebugDataLoad.Request) {
        self.fetchDebugData().done { data in
            self.presenter.presentDebugData(response: .init(data: data))
        }
    }

    private func fetchDebugData() -> Guarantee<DebugMenu.DebugData> {
        self.provider.fetchFCMRegistrationToken().then { fcmTokenResult in
            let data = DebugMenu.DebugData(fcmRegistrationToken: fcmTokenResult)
            return .value(data)
        }
    }
}
