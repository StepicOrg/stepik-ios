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

    private let remoteConfig: RemoteConfig

    init(
        presenter: CourseListsCollectionPresenterProtocol,
        provider: CourseListsCollectionProviderProtocol,
        remoteConfig: RemoteConfig
    ) {
        self.presenter = presenter
        self.provider = provider
        self.remoteConfig = remoteConfig
    }

    func doCourseListsFetch(request: CourseListsCollection.CourseListsLoad.Request) {
        self.provider.fetchCachedCourseLists().then { cachedCourseLists -> Promise<[CourseListModel]> in
            // Pass cached data to presenter and start fetching from remote
            self.presentAvailableCourseLists(cachedCourseLists)

            return self.provider.fetchRemoteCourseLists()
        }.done { remoteCourseLists in
            self.presentAvailableCourseLists(remoteCourseLists)
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

    private func presentAvailableCourseLists(_ courseLists: [CourseListModel]) {
        let hiddenCourseListsIDs = Set(self.remoteConfig.hiddenCourseListsIDs)
        let finalCourseLists = hiddenCourseListsIDs.isEmpty
            ? courseLists
            : courseLists.filter { !hiddenCourseListsIDs.contains($0.id) }

        self.presenter.presentCourses(response: .init(result: .success(finalCourseLists)))
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension CourseListsCollectionInteractor: CourseListOutputProtocol {
    func presentCourseInfo(course: Course) {
        self.moduleOutput?.presentCourseInfo(course: course)
    }

    func presentCourseSyllabus(course: Course) {
        self.moduleOutput?.presentCourseSyllabus(course: course)
    }

    func presentLastStep(course: Course, isAdaptive: Bool) {
        self.moduleOutput?.presentLastStep(course: course, isAdaptive: isAdaptive)
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
