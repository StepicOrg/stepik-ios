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
        self.currentUserID = user.id
        self.doCoursesLoad(request: .init())
    }
}

extension NewProfileCreatedCoursesInteractor: CourseListOutputProtocol {
    func presentCourseInfo(course: Course, viewSource: AnalyticsEvent.CourseViewSource) {
        self.presenter.presentCourseInfo(response: .init(course: course, courseViewSource: viewSource))
    }

    func presentCourseSyllabus(course: Course, viewSource: AnalyticsEvent.CourseViewSource) {
        self.presenter.presentCourseSyllabus(response: .init(course: course, courseViewSource: viewSource))
    }

    func presentLastStep(
        course: Course,
        isAdaptive: Bool,
        source: AnalyticsEvent.CourseContinueSource,
        viewSource: AnalyticsEvent.CourseViewSource
    ) {
        self.presenter.presentLastStep(
            response: .init(
                course: course,
                isAdaptive: isAdaptive,
                courseContinueSource: source,
                courseViewSource: viewSource
            )
        )
    }

    func presentAuthorization() {
        self.presenter.presentAuthorization(response: .init())
    }

    func presentPaidCourseInfo(course: Course) {
        self.presentCourseInfo(course: course, viewSource: .profile(id: self.currentUserID.require()))
    }

    func presentEmptyState(sourceModule: CourseListInputProtocol) {
        self.moduleOutput?.handleCreatedCoursesEmptyState()
    }

    func presentError(sourceModule: CourseListInputProtocol) {
        self.presenter.presentError(response: .init())
    }

    func presentLoadedState(sourceModule: CourseListInputProtocol) {}
}
