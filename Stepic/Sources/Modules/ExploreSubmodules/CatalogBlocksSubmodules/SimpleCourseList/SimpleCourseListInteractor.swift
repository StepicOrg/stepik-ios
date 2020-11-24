import Foundation
import PromiseKit

protocol SimpleCourseListInteractorProtocol {
    func doCourseListLoad(request: SimpleCourseList.CourseListLoad.Request)
}

final class SimpleCourseListInteractor: SimpleCourseListInteractorProtocol {
    weak var moduleOutput: SimpleCourseListOutputProtocol?

    private let presenter: SimpleCourseListPresenterProtocol
    private let provider: SimpleCourseListProviderProtocol

    private let catalogBlockID: CatalogBlock.IdType

    init(
        catalogBlockID: CatalogBlock.IdType,
        presenter: SimpleCourseListPresenterProtocol,
        provider: SimpleCourseListProviderProtocol
    ) {
        self.catalogBlockID = catalogBlockID
        self.presenter = presenter
        self.provider = provider
    }

    func doCourseListLoad(request: SimpleCourseList.CourseListLoad.Request) {
        self.fetchCatalogBlock().done { catalogBlockOrNil in
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

            self.presenter.presentCourseList(response: .init(result: .success(contentItems)))
        }.catch { error in
            print("SimpleCourseListInteractor :: failed fetch catalog block with error = \(error)")
            self.presenter.presentCourseList(response: .init(result: .failure(error)))
        }
    }

    private func fetchCatalogBlock() -> Promise<CatalogBlock?> {
        self.provider.fetchCachedCatalogBlock(
            id: self.catalogBlockID
        ).then { cachedCatalogBlockOrNil -> Promise<CatalogBlock?> in
            if let cachedCatalogBlock = cachedCatalogBlockOrNil {
                return .value(cachedCatalogBlock)
            }
            return self.provider.fetchRemoteCatalogBlock(id: self.catalogBlockID)
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case invalidKind
        case unsupportedAppearance
    }
}

extension SimpleCourseListInteractor: SimpleCourseListInputProtocol {}
