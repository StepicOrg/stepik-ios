import UIKit

protocol NewProfileUserActivityPresenterProtocol {
    func presentUserActivity(response: NewProfileUserActivity.ActivityLoad.Response)
}

final class NewProfileUserActivityPresenter: NewProfileUserActivityPresenterProtocol {
    weak var viewController: NewProfileUserActivityViewControllerProtocol?

    func presentUserActivity(response: NewProfileUserActivity.ActivityLoad.Response) {
        switch response.result {
        case .success(let userActivity):
            let viewModel = self.makeViewModel(userActivity: userActivity)
            self.viewController?.displayUserActivity(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayUserActivity(viewModel: .init(state: .error))
        }
    }

    private func makeViewModel(userActivity: UserActivity) -> NewProfileUserActivityViewModel {
        let currentStreakText = userActivity.currentStreak > 0
            ? String(
                format: NSLocalizedString("NewProfileUserActivityCurrentStreak", comment: ""),
                arguments: [FormatterHelper.daysCount(userActivity.currentStreak)]
              )
            : NSLocalizedString("NewProfileUserActivityNoCurrentStreak", comment: "")

        let longestStreakText = userActivity.longestStreak > 0
            ? String(
                format: NSLocalizedString("NewProfileUserActivityLongestStreak", comment: ""),
                arguments: [FormatterHelper.daysCount(userActivity.longestStreak)]
              )
            : ""

        return NewProfileUserActivityViewModel(
            didSolveToday: userActivity.didSolveToday,
            currentStreakText: currentStreakText,
            longestStreakText: longestStreakText,
            pins: userActivity.pins
        )
    }
}
