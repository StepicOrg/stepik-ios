import UIKit

protocol DebugMenuPresenterProtocol {
    func presentDebugData(response: DebugMenu.DebugDataLoad.Response)
}

final class DebugMenuPresenter: DebugMenuPresenterProtocol {
    weak var viewController: DebugMenuViewControllerProtocol?

    func presentDebugData(response: DebugMenu.DebugDataLoad.Response) {
        let viewModel = self.makeViewModel(data: response.data)
        self.viewController?.displayDebugData(viewModel: .init(state: .result(data: viewModel)))
    }

    private func makeViewModel(data: DebugMenu.DebugData) -> DebugMenuViewModel {
        let fcmRegistrationToken: String = {
            switch data.fcmRegistrationToken {
            case .success(let token):
                return token
            case .failure(let error):
                return error.localizedDescription
            }
        }()

        return DebugMenuViewModel(fcmRegistrationToken: fcmRegistrationToken)
    }
}
