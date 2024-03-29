import UIKit

protocol HomePresenterProtocol: BaseExplorePresenterProtocol {
    func presentStreakActivity(response: Home.StreakLoad.Response)
    func presentContent(response: Home.ContentLoad.Response)
    func presentCourseListState(response: Home.CourseListStateUpdate.Response)
}

final class HomePresenter: BaseExplorePresenter, HomePresenterProtocol {
    lazy var homeViewController = self.viewController as? HomeViewControllerProtocol

    func presentStreakActivity(response: Home.StreakLoad.Response) {
        var viewModel: Home.StreakLoad.ViewModel

        switch response.result {
        case .hidden:
            viewModel = .init(result: .hidden)
        case .success(let currentStreak, let needsToSolveToday):
            if currentStreak > 0 {
                viewModel = .init(
                    result: .visible(
                        message: self.makeStreakActivityMessage(
                            days: currentStreak,
                            needsToSolveToday: needsToSolveToday
                        ),
                        streak: currentStreak
                    )
                )
            } else {
                viewModel = .init(result: .hidden)
            }
        }

        self.homeViewController?.displayStreakInfo(viewModel: viewModel)
    }

    func presentContent(response: Home.ContentLoad.Response) {
        self.homeViewController?.displayContent(
            viewModel: .init(
                isAuthorized: response.isAuthorized,
                contentLanguage: response.contentLanguage,
                promoBanners: response.promoBanners
            )
        )
    }

    func presentCourseListState(response: Home.CourseListStateUpdate.Response) {
        self.homeViewController?.displayModuleErrorState(
            viewModel: .init(
                module: response.module,
                result: response.result
            )
        )
    }

    private func makeStreakActivityMessage(days: Int, needsToSolveToday: Bool) -> String {
        let pluralizedDaysCnt = StringHelper.pluralize(
            number: days,
            forms: [
                NSLocalizedString("days1", comment: ""),
                NSLocalizedString("days234", comment: ""),
                NSLocalizedString("days567890", comment: "")
            ]
        )
        var countText = String(
            format: NSLocalizedString("SolveStreaksDaysCount", comment: ""),
            "\(days)",
            "\(pluralizedDaysCnt)"
        )

        if needsToSolveToday {
            countText += "\n\(NSLocalizedString("SolveSomethingToday", comment: ""))"
        }

        return countText
    }
}
