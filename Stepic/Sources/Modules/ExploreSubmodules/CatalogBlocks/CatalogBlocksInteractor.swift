import Foundation
import PromiseKit

protocol CatalogBlocksInteractorProtocol: AnyObject {
    func doCatalogBlocksLoad(request: CatalogBlocks.CatalogBlocksLoad.Request)
    func doFullCourseListPresentation(
        request: CatalogBlocks.FullCourseListModulePresentation.Request
    )
}

final class CatalogBlocksInteractor: CatalogBlocksInteractorProtocol {
    weak var moduleOutput: CatalogBlocksOutputProtocol?

    private let presenter: CatalogBlocksPresenterProtocol
    private let provider: CatalogBlocksProviderProtocol

    private var didPresentCatalogBlocks = false

    init(
        presenter: CatalogBlocksPresenterProtocol,
        provider: CatalogBlocksProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doCatalogBlocksLoad(request: CatalogBlocks.CatalogBlocksLoad.Request) {
        self.provider.fetchCachedCatalogBlocks().then { cachedCatalogBlocks -> Promise<[CatalogBlock]> in
            if !cachedCatalogBlocks.isEmpty {
                self.didPresentCatalogBlocks = true
                self.presenter.presentCatalogBlocks(response: .init(result: .success(cachedCatalogBlocks)))
            }

            return self.provider.fetchRemoteCatalogBlocks()
        }.done { remoteCatalogBlocks in
            if remoteCatalogBlocks.isEmpty {
                self.moduleOutput?.hideCatalogBlocks()
            } else {
                self.didPresentCatalogBlocks = true
                self.presenter.presentCatalogBlocks(response: .init(result: .success(remoteCatalogBlocks)))
            }
        }.catch { error in
            if case CatalogBlocksProvider.Error.networkFetchFailed = error,
               !self.didPresentCatalogBlocks {
                self.presenter.presentCatalogBlocks(response: .init(result: .failure(error)))
            }
        }
    }

    func doFullCourseListPresentation(request: CatalogBlocks.FullCourseListModulePresentation.Request) {
        self.moduleOutput?.presentCourseList(
            type: request.courseListType,
            presentationDescription: request.presentationDescription
        )
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
    func presentSimpleCourseList(
        type: CatalogBlockCourseListType,
        presentationDescription: CourseList.PresentationDescription?
    ) {
        self.moduleOutput?.presentCourseList(type: type, presentationDescription: presentationDescription)
    }
}

extension CatalogBlocksInteractor: AuthorsCourseListOutputProtocol {
    func presentAuthor(id: User.IdType) {
        self.moduleOutput?.presentProfile(id: id)
    }
}
