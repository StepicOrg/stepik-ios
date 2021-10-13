import Foundation
import PromiseKit

protocol BaseExploreInteractorProtocol {
    func doFullscreenCourseListPresentation(request: BaseExplore.FullscreenCourseListModulePresentation.Request)
    func doOnlineModeReset(request: BaseExplore.TryToSetOnline.Request)
}

class BaseExploreInteractor: BaseExploreInteractorProtocol, CourseListOutputProtocol {
    let presenter: BaseExplorePresenterProtocol
    let contentLanguageService: ContentLanguageServiceProtocol
    let networkReachabilityService: NetworkReachabilityServiceProtocol

    init(
        presenter: BaseExplorePresenterProtocol,
        contentLanguageService: ContentLanguageServiceProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol
    ) {
        self.presenter = presenter
        self.contentLanguageService = contentLanguageService
        self.networkReachabilityService = networkReachabilityService
    }

    func doFullscreenCourseListPresentation(request: BaseExplore.FullscreenCourseListModulePresentation.Request) {
        self.presenter.presentFullscreenCourseList(
            response: .init(
                presentationDescription: request.presentationDescription,
                courseListType: request.courseListType
            )
        )
    }

    func doOnlineModeReset(request: BaseExplore.TryToSetOnline.Request) {
        if self.networkReachabilityService.isReachable {
            for module in request.modules {
                module.setOnlineStatus()
            }
        }
    }

    // MARK: - CourseListOutputProtocol

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
        self.presenter.presentPaidCourseBuying(response: .init(course: course))
    }

    func presentEmptyState(sourceModule: CourseListInputProtocol) {}

    func presentError(sourceModule: CourseListInputProtocol) {}

    func presentLoadedState(sourceModule: CourseListInputProtocol) {}
}
