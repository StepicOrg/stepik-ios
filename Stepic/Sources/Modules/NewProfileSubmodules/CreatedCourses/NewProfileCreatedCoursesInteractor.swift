import Foundation
import PromiseKit

protocol NewProfileCreatedCoursesInteractorProtocol {
    func doCoursesLoad(request: NewProfileCreatedCourses.CoursesLoad.Request)
    func doOnlineModeReset(request: NewProfileCreatedCourses.OnlineModeReset.Request)
}

final class NewProfileCreatedCoursesInteractor: NewProfileCreatedCoursesInteractorProtocol {
    weak var moduleOutput: NewProfileCreatedCoursesOutputProtocol?

    private let presenter: NewProfileCreatedCoursesPresenterProtocol
    private let networkReachabilityService: NetworkReachabilityServiceProtocol

    private var currentUserID: User.IdType?

    init(
        presenter: NewProfileCreatedCoursesPresenterProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol
    ) {
        self.presenter = presenter
        self.networkReachabilityService = networkReachabilityService
    }

    func doCoursesLoad(request: NewProfileCreatedCourses.CoursesLoad.Request) {
        if let currentUserID = self.currentUserID {
            self.presenter.presentCourses(response: .init(teacherID: currentUserID))
        }
    }

    func doOnlineModeReset(request: NewProfileCreatedCourses.OnlineModeReset.Request) {
        if self.networkReachabilityService.isReachable {
            request.module.setOnlineStatus()
        }
    }
}

extension NewProfileCreatedCoursesInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool) {
        if self.currentUserID != user.id {
            self.currentUserID = user.id
            self.doCoursesLoad(request: .init())
        }
    }
}

extension NewProfileCreatedCoursesInteractor: CourseListOutputProtocol {
    func presentCourseInfo(course: Course, viewSource: AnalyticsEvent.CourseViewSource) {}

    func presentCourseSyllabus(course: Course, viewSource: AnalyticsEvent.CourseViewSource) {}

    func presentLastStep(course: Course, isAdaptive: Bool, viewSource: AnalyticsEvent.CourseViewSource) {}

    func presentAuthorization() {}

    func presentPaidCourseInfo(course: Course) {}

    func presentEmptyState(sourceModule: CourseListInputProtocol) {}

    func presentError(sourceModule: CourseListInputProtocol) {}
}
