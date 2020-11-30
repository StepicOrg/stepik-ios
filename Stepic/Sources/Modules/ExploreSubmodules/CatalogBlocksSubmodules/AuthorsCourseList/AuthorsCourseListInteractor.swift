import Foundation
import PromiseKit

protocol AuthorsCourseListInteractorProtocol {
    func doCourseListLoad(request: AuthorsCourseList.CourseListLoad.Request)
    func doAuthorPresentation(request: AuthorsCourseList.AuthorPresentation.Request)
}

final class AuthorsCourseListInteractor: AuthorsCourseListInteractorProtocol {
    weak var moduleOutput: AuthorsCourseListOutputProtocol?

    private let presenter: AuthorsCourseListPresenterProtocol
    private let provider: AuthorsCourseListProviderProtocol

    private let catalogBlockID: CatalogBlock.IdType
    private var currentCatalogBlock: CatalogBlock?

    init(
        catalogBlockID: CatalogBlock.IdType,
        presenter: AuthorsCourseListPresenterProtocol,
        provider: AuthorsCourseListProviderProtocol
    ) {
        self.catalogBlockID = catalogBlockID
        self.presenter = presenter
        self.provider = provider
    }

    func doCourseListLoad(request: AuthorsCourseList.CourseListLoad.Request) {
        self.fetchCatalogBlock().done { catalogBlockOrNil in
            self.currentCatalogBlock = catalogBlockOrNil

            guard let catalogBlock = catalogBlockOrNil,
                  let contentItems = catalogBlock.content as? [AuthorsCatalogBlockContentItem] else {
                throw Error.fetchFailed
            }

            guard catalogBlock.kind == .authors else {
                throw Error.invalidKind
            }

            self.presenter.presentCourseList(response: .init(result: .success(contentItems)))
        }.catch { error in
            print("AuthorsCourseListInteractor :: failed fetch catalog block with error = \(error)")
            self.presenter.presentCourseList(response: .init(result: .failure(error)))
        }
    }

    func doAuthorPresentation(request: AuthorsCourseList.AuthorPresentation.Request) {
        guard let contentItems = self.currentCatalogBlock?.content as? [AuthorsCatalogBlockContentItem],
              let selectedItem = contentItems.first(where: { "\($0.id)" == request.uniqueIdentifier })  else {
            return
        }

        self.moduleOutput?.presentAuthor(id: selectedItem.id)
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
    }
}
