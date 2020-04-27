import Foundation
import PromiseKit

protocol UserCoursesInteractorProtocol {
    func doUserCoursesFetch(request: UserCourses.UserCoursesLoad.Request)
}

final class UserCoursesInteractor: UserCoursesInteractorProtocol {
    private let presenter: UserCoursesPresenterProtocol
    private let provider: UserCoursesProviderProtocol

    init(
        presenter: UserCoursesPresenterProtocol,
        provider: UserCoursesProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doUserCoursesFetch(request: UserCourses.UserCoursesLoad.Request) {
        self.presenter.presentUserCourses(response: .init())
    }

    enum Error: Swift.Error {
        case something
    }
}
