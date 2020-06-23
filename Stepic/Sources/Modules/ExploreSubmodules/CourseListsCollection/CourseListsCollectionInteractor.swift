import Foundation
import PromiseKit

protocol CourseListsCollectionInteractorProtocol: AnyObject {
    func doCourseListsFetch(request: CourseListsCollection.CourseListsLoad.Request)
    func doFullscreenCourseListPresentation(
        request: CourseListsCollection.FullscreenCourseListModulePresentation.Request
    )
}

final class CourseListsCollectionInteractor: CourseListsCollectionInteractorProtocol {
    weak var moduleOutput: (CourseListCollectionOutputProtocol & CourseListOutputProtocol)?

    private let presenter: CourseListsCollectionPresenterProtocol
    private let provider: CourseListsCollectionProviderProtocol

    init(
        presenter: CourseListsCollectionPresenterProtocol,
        provider: CourseListsCollectionProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doCourseListsFetch(request: CourseListsCollection.CourseListsLoad.Request) {
        self.provider.fetchCachedCourseLists().then { cachedCourseLists -> Promise<[CourseListModel]> in
            // Pass cached data to presenter and start fetching from remote
            self.presenter.presentCourses(response: .init(result: .success(cachedCourseLists)))

            return self.provider.fetchRemoteCourseLists()
        }.done { remoteCourseLists in
            self.presenter.presentCourses(response: .init(result: .success(remoteCourseLists)))
        }.catch { _ in }
    }

    func doFullscreenCourseListPresentation(
        request: CourseListsCollection.FullscreenCourseListModulePresentation.Request
    ) {
        guard let collectionCourseListType = request.courseListType as? CollectionCourseListType else {
            return
        }

        self.moduleOutput?.presentCourseList(
            presentationDescription: request.presentationDescription,
            type: collectionCourseListType
        )
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension CourseListsCollectionInteractor: CourseListOutputProtocol {
    func presentCourseInfo(course: Course, viewSource: AnalyticsEvent.CourseViewSource) {
        self.moduleOutput?.presentCourseInfo(course: course, viewSource: viewSource)
    }

    func presentCourseSyllabus(course: Course, viewSource: AnalyticsEvent.CourseViewSource) {
        self.moduleOutput?.presentCourseSyllabus(course: course, viewSource: viewSource)
    }

    func presentLastStep(course: Course, isAdaptive: Bool, viewSource: AnalyticsEvent.CourseViewSource) {
        self.moduleOutput?.presentLastStep(course: course, isAdaptive: isAdaptive, viewSource: viewSource)
    }

    func presentAuthorization() {
        self.moduleOutput?.presentAuthorization()
    }

    func presentPaidCourseInfo(course: Course) {
        self.moduleOutput?.presentPaidCourseInfo(course: course)
    }

    func presentEmptyState(sourceModule: CourseListInputProtocol) {}

    func presentError(sourceModule: CourseListInputProtocol) {}
}
