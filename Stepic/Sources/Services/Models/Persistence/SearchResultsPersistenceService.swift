import Foundation
import PromiseKit

protocol SearchResultsPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class SearchResultsPersistenceService: BasePersistenceService<SearchResult>,
                                             SearchResultsPersistenceServiceProtocol {}
