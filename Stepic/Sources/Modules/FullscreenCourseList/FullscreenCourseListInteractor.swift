import Foundation
import PromiseKit

protocol FullscreenCourseListInteractorProtocol: CourseListOutputProtocol {
    func doOnlineModeReset(request: FullscreenCourseList.OnlineModeReset.Request)
}

final class FullscreenCourseListInteractor: FullscreenCourseListInteractorProtocol {
    let presenter: FullscreenCourseListPresenterProtocol
    let networkReachabilityService: NetworkReachabilityServiceProtocol

    init(
        presenter: FullscreenCourseListPresenterProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol
    ) {
        self.presenter = presenter
        self.networkReachabilityService = networkReachabilityService
    }

    func doOnlineModeReset(request: FullscreenCourseList.OnlineModeReset.Request) {
        if self.networkReachabilityService.isReachable {
            request.module.setOnlineStatus()
        }
    }

    // MARK: - CourseListOutputProtocol

    func presentCourseInfo(course: Course, viewSource: AnalyticsEvent.CourseViewSource) {
        self.presenter.presentCourseInfo(response: .init(course: course, courseViewSource: viewSource))
    }

    func presentCourseSyllabus(course: Course, viewSource: AnalyticsEvent.CourseViewSource) {
        self.presenter.presentCourseSyllabus(response: .init(course: course, courseViewSource: viewSource))
    }

    func presentLastStep(course: Course, isAdaptive: Bool, viewSource: AnalyticsEvent.CourseViewSource) {
        self.presenter.presentLastStep(
            response: .init(course: course, isAdaptive: isAdaptive, courseViewSource: viewSource)
        )
    }

    func presentAuthorization() {
        self.presenter.presentAuthorization(response: .init())
    }

    func presentEmptyState(sourceModule: CourseListInputProtocol) {
        self.presenter.presentPlaceholder(response: .init(state: .empty))
    }

    func presentError(sourceModule: CourseListInputProtocol) {
        self.presenter.presentPlaceholder(response: .init(state: .error))
    }

    func presentPaidCourseInfo(course: Course) {
        self.presenter.presentPaidCourseBuying(response: .init(course: course))
    }

    func presentLoadedState(sourceModule: CourseListInputProtocol) {
        self.presenter.presentHidePlaceholder(response: .init())
    }
}
