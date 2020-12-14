import Foundation
import PromiseKit

protocol SimpleCourseListInteractorProtocol {
    func doCourseListLoad(request: SimpleCourseList.CourseListLoad.Request)
    func doCourseListPresentation(request: SimpleCourseList.CourseListModulePresentation.Request)
}

final class SimpleCourseListInteractor: SimpleCourseListInteractorProtocol {
    weak var moduleOutput: SimpleCourseListOutputProtocol?

    private let presenter: SimpleCourseListPresenterProtocol
    private let provider: SimpleCourseListProviderProtocol

    private let initialContext: SimpleCourseList.Context
    private var currentCourseListData: SimpleCourseList.CourseListData?

    init(
        initialContext: SimpleCourseList.Context,
        presenter: SimpleCourseListPresenterProtocol,
        provider: SimpleCourseListProviderProtocol
    ) {
        self.initialContext = initialContext
        self.presenter = presenter
        self.provider = provider
    }

    func doCourseListLoad(request: SimpleCourseList.CourseListLoad.Request) {
        self.refreshCourseList()
    }

    func doCourseListPresentation(request: SimpleCourseList.CourseListModulePresentation.Request) {
        guard let courseListData = self.currentCourseListData else {
            return
        }

        switch courseListData {
        case .catalogBlockContentItems(let contentItems):
            guard let selectedItem = contentItems.first(where: { "\($0.id)" == request.uniqueIdentifier }) else {
                return
            }

            let courseListType = CatalogBlockCourseListType(
                courseListID: selectedItem.id,
                coursesIDs: selectedItem.courses
            )

            self.moduleOutput?.presentSimpleCourseList(type: courseListType)
        case .courseLists(let courseLists):
            guard let selectedCourseList = courseLists.first(where: { "\($0.id)" == request.uniqueIdentifier }) else {
                return
            }

            let courseListType = CatalogBlockCourseListType(
                courseListID: selectedCourseList.id,
                coursesIDs: selectedCourseList.coursesArray
            )

            self.moduleOutput?.presentSimpleCourseList(type: courseListType)
        }
    }

    // MARK: Private API

    private func refreshCourseList() {
        switch self.initialContext {
        case .catalogBlock(let catalogBlockID):
            self.fetchCatalogBlock(id: catalogBlockID).done { catalogBlockOrNil in
                guard let catalogBlock = catalogBlockOrNil,
                      let contentItems = catalogBlock.content as? [SimpleCourseListsCatalogBlockContentItem] else {
                    throw Error.fetchFailed
                }

                guard catalogBlock.kind == .simpleCourseLists else {
                    throw Error.invalidKind
                }

                guard catalogBlock.appearance == .default else {
                    throw Error.unsupportedAppearance
                }

                let courseListData: SimpleCourseList.CourseListData = .catalogBlockContentItems(contentItems)
                self.currentCourseListData = courseListData

                self.presenter.presentCourseList(response: .init(result: .success(courseListData)))
            }.catch { error in
                print("SimpleCourseListInteractor :: failed fetch catalog block with error = \(error)")
                self.presenter.presentCourseList(response: .init(result: .failure(error)))
            }
        case .courseLists(let ids):
            self.provider.fetchCourseLists(ids: ids).done { fetchResult in
                let courseListData: SimpleCourseList.CourseListData = .courseLists(fetchResult.value)
                self.currentCourseListData = courseListData

                self.presenter.presentCourseList(response: .init(result: .success(courseListData)))
            }.catch { error in
                print("SimpleCourseListInteractor :: failed fetch course lists with error = \(error)")
                self.presenter.presentCourseList(response: .init(result: .failure(error)))
            }
        }
    }

    private func fetchCatalogBlock(id: CatalogBlock.IdType) -> Promise<CatalogBlock?> {
        self.provider.fetchCachedCatalogBlock(
            id: id
        ).then { cachedCatalogBlockOrNil -> Promise<CatalogBlock?> in
            if let cachedCatalogBlock = cachedCatalogBlockOrNil {
                return .value(cachedCatalogBlock)
            }
            return self.provider.fetchRemoteCatalogBlock(id: id)
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case invalidKind
        case unsupportedAppearance
    }
}
