import Foundation
import PromiseKit

protocol UserCoursesInteractorProtocol {
    func doUserCoursesFetch(request: UserCourses.UserCoursesLoad.Request)
}

final class UserCoursesInteractor: UserCoursesInteractorProtocol {
    private let presenter: UserCoursesPresenterProtocol

    init(presenter: UserCoursesPresenterProtocol) {
        self.presenter = presenter
    }

    func doUserCoursesFetch(request: UserCourses.UserCoursesLoad.Request) {
        self.presenter.presentUserCourses(response: .init())
    }
}
