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
        let streakText: String = {
            if userActivity.currentStreak > 0 {
                return String(
                    format: NSLocalizedString("NewProfileUserActivityCurrentStreak", comment: ""),
                    arguments: [FormatterHelper.daysCount(userActivity.currentStreak)]
                )
            } else {
                return NSLocalizedString("NewProfileUserActivityNoCurrentStreak", comment: "")
            }
        }()

        return NewProfileActivityViewModel(
            didSolveToday: userActivity.didSolveToday,
            streakText: streakText,
            pins: userActivity.pins
        )
    }
}
