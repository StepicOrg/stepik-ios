import Foundation
import PromiseKit

protocol HomeInteractorProtocol: BaseExploreInteractorProtocol {
    func doStreakActivityLoad(request: Home.StreakLoad.Request)
    func doContentLoad(request: Home.ContentLoad.Request)
}

final class HomeInteractor: BaseExploreInteractor, HomeInteractorProtocol {
    private let provider: HomeProviderProtocol
    private let userAccountService: UserAccountServiceProtocol

    private lazy var homePresenter = self.presenter as? HomePresenterProtocol

    init(
        presenter: HomePresenterProtocol,
        provider: HomeProviderProtocol,
        userAccountService: UserAccountServiceProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol,
        contentLanguageService: ContentLanguageServiceProtocol
    ) {
        self.provider = provider
        self.userAccountService = userAccountService
        super.init(
            presenter: presenter,
            contentLanguageService: contentLanguageService,
            networkReachabilityService: networkReachabilityService
        )
    }

    func doStreakActivityLoad(request: Home.StreakLoad.Request) {
        guard let user = self.userAccountService.currentUser else {
            self.homePresenter?.presentStreakActivity(response: .init(result: .hidden))
            return
        }

        self.provider.fetchUserActivity(user: user).done { activity in
            self.homePresenter?.presentStreakActivity(
                response: .init(
                    result: .success(
                        currentStreak: activity.currentStreak,
                        needsToSolveToday: activity.needsToSolveToday
                    )
                )
            )
        }.catch { _ in
            self.homePresenter?.presentStreakActivity(response: .init(result: .hidden))
        }
    }

    func doContentLoad(request: Home.ContentLoad.Request) {
        self.homePresenter?.presentContent(
            response: .init(
                isAuthorized: self.userAccountService.isAuthorized,
                contentLanguage: self.contentLanguageService.globalContentLanguage
            )
        )
    }

    override func presentEmptyState(sourceModule: CourseListInputProtocol) {
        self.homePresenter?.presentCourseListState(
            response: .init(
                module: self.determineModule(sourceModule: sourceModule),
                result: .empty
            )
        )
    }

    override func presentError(sourceModule: CourseListInputProtocol) {
        self.homePresenter?.presentCourseListState(
            response: .init(
                module: self.determineModule(sourceModule: sourceModule),
                result: .error
            )
        )
    }

    private func determineModule(sourceModule: CourseListInputProtocol) -> Home.Submodule {
        if sourceModule.moduleIdentifier == Home.Submodule.enrolledCourses.uniqueIdentifier {
            return .enrolledCourses
        } else if sourceModule.moduleIdentifier == Home.Submodule.popularCourses.uniqueIdentifier {
            return .popularCourses
        } else {
            fatalError("Unrecognized submodule")
        }
    }
}

extension HomeInteractor: ContinueCourseOutputProtocol {
    func hideContinueCourse() {
        self.homePresenter?.presentCourseListState(
            response: .init(
                module: Home.Submodule.continueCourse,
                result: .empty
            )
        )
    }
}
