import UIKit

protocol NewProfileActivityPresenterProtocol {
    func presentUserActivity(response: NewProfileActivity.ActivityLoad.Response)
}

final class NewProfileActivityPresenter: NewProfileActivityPresenterProtocol {
    weak var viewController: NewProfileActivityViewControllerProtocol?

    func presentUserActivity(response: NewProfileActivity.ActivityLoad.Response) {
        switch response.result {
        case .success(let userActivity):
            let viewModel = self.makeViewModel(userActivity: userActivity)
            self.viewController?.displayUserActivity(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayUserActivity(viewModel: .init(state: .error))
        }
    }

    private func makeViewModel(userActivity: UserActivity) -> NewProfileActivityViewModel {
        NewProfileActivityViewModel(currentStreak: userActivity.currentStreak, pins: userActivity.pins)
    }
}
