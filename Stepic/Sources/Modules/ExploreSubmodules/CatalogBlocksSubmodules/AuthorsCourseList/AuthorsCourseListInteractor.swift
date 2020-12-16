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

    private let initialContext: AuthorsCourseList.Context

    init(
        initialContext: AuthorsCourseList.Context,
        presenter: AuthorsCourseListPresenterProtocol,
        provider: AuthorsCourseListProviderProtocol
    ) {
        self.initialContext = initialContext
        self.presenter = presenter
        self.provider = provider
    }

    func doCourseListLoad(request: AuthorsCourseList.CourseListLoad.Request) {
        self.refreshCourseList()
    }

    func doAuthorPresentation(request: AuthorsCourseList.AuthorPresentation.Request) {
        if let authorID = Int(request.uniqueIdentifier) {
            self.moduleOutput?.presentAuthor(id: authorID)
        }
    }

    // MARK: Private API

    private func refreshCourseList() {
        switch self.initialContext {
        case .catalogBlock(let catalogBlockID):
            self.fetchCatalogBlock(id: catalogBlockID).done { catalogBlockOrNil in
                guard let catalogBlock = catalogBlockOrNil,
                      let contentItems = catalogBlock.content as? [AuthorsCatalogBlockContentItem] else {
                    throw Error.fetchFailed
                }

                guard catalogBlock.kind == .authors else {
                    throw Error.invalidKind
                }

                self.presenter.presentCourseList(
                    response: .init(result: .success(.catalogBlockContentItems(contentItems)))
                )
            }.catch { error in
                print("AuthorsCourseListInteractor :: failed fetch catalog block with error = \(error)")
                self.presenter.presentCourseList(response: .init(result: .failure(error)))
            }
        case .authors(let authorsIDs):
            self.provider.fetchUsers(ids: authorsIDs).done { fetchResult in
                let users = fetchResult.value
                self.presenter.presentCourseList(response: .init(result: .success(.users(users))))
            }.catch { error in
                print("AuthorsCourseListInteractor :: failed fetch authors with error = \(error)")
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
    }
}
