import Foundation
import PromiseKit

protocol CatalogBlocksInteractorProtocol {
    func doCatalogBlocksLoad(request: CatalogBlocks.CatalogBlocksLoad.Request)
    func doFullCourseListPresentation(
        request: CatalogBlocks.FullCourseListModulePresentation.Request
    )
}

final class CatalogBlocksInteractor: CatalogBlocksInteractorProtocol {
    weak var moduleOutput: CatalogBlocksOutputProtocol?

    private let presenter: CatalogBlocksPresenterProtocol
    private let provider: CatalogBlocksProviderProtocol

    init(
        presenter: CatalogBlocksPresenterProtocol,
        provider: CatalogBlocksProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doCatalogBlocksLoad(request: CatalogBlocks.CatalogBlocksLoad.Request) {
        self.provider.fetchCachedCatalogBlocks().then { cachedCatalogBlocks -> Promise<[CatalogBlock]> in
            self.presenter.presentCatalogBlocks(response: .init(result: .success(cachedCatalogBlocks)))
            return self.provider.fetchRemoteCatalogBlocks()
        }.done { remoteCatalogBlocks in
            self.presenter.presentCatalogBlocks(response: .init(result: .success(remoteCatalogBlocks)))
        }.catch { _ in }
    }

    func doFullCourseListPresentation(request: CatalogBlocks.FullCourseListModulePresentation.Request) {
        self.moduleOutput?.presentCourseList(type: request.courseListType)
    }
}

// MARK: - CatalogBlocksInteractor: CourseListOutputProtocol -

extension CatalogBlocksInteractor: CourseListOutputProtocol {
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

    func presentLoadedState(sourceModule: CourseListInputProtocol) {}
}

extension CatalogBlocksInteractor: SimpleCourseListOutputProtocol {
    func presentSimpleCourseList(type: CatalogBlockCourseListType) {
        self.moduleOutput?.presentCourseList(type: type)
    }
}

extension CatalogBlocksInteractor: AuthorsCourseListOutputProtocol {
    func presentAuthor(id: User.IdType) {
        self.moduleOutput?.presentProfile(id: id)
    }
}
