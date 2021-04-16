import UIKit

protocol NewProfileUserActivityPresenterProtocol {
    func presentUserActivity(response: NewProfileUserActivity.ActivityLoad.Response)
}

final class NewProfileUserActivityPresenter: NewProfileUserActivityPresenterProtocol {
    weak var viewController: NewProfileUserActivityViewControllerProtocol?

    func presentUserActivity(response: NewProfileUserActivity.ActivityLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makeViewModel(
                userActivity: data.userActivity,
                isCurrentUserProfile: data.isCurrentUserProfile
            )
            self.viewController?.displayUserActivity(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayUserActivity(viewModel: .init(state: .error))
        }
    }

    private func makeViewModel(
        userActivity: UserActivity,
        isCurrentUserProfile: Bool
    ) -> NewProfileUserActivityViewModel {
        let currentStreakText: String = {
            if userActivity.currentStreak > 0 {
                return String(
                    format: NSLocalizedString("NewProfileUserActivityCurrentStreak", comment: ""),
                    arguments: [FormatterHelper.daysCount(userActivity.currentStreak)]
                )
            } else if isCurrentUserProfile {
                return NSLocalizedString("NewProfileUserActivityNoCurrentStreak", comment: "")
            } else {
                return ""
            }
        }()

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
