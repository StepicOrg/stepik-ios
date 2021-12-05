import Foundation
import PromiseKit

protocol WishlistWidgetProviderProtocol {
    func fetchWishlistCoursesIDs(from dataSourceType: DataSourceType) -> Promise<[Course.IdType]>
}

final class WishlistWidgetProvider: WishlistWidgetProviderProtocol {
    private let wishlistRepository: WishlistRepositoryProtocol
    private let userAccountService: UserAccountServiceProtocol

    init(
        wishlistRepository: WishlistRepositoryProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.wishlistRepository = wishlistRepository
        self.userAccountService = userAccountService
    }

    func fetchWishlistCoursesIDs(from dataSourceType: DataSourceType) -> Promise<[Course.IdType]> {
        guard self.userAccountService.isAuthorized else {
            switch dataSourceType {
            case .cache:
                return Promise(error: Error.cacheFetchFailed)
            case .remote:
                return Promise(error: Error.remoteFetchFailed)
            }
        }

        return Promise { seal in
            self.wishlistRepository.fetchWishlistEntries(sourceType: dataSourceType).done { wishlistEntries in
                let wishlistCoursesIDs = wishlistEntries.map(\.courseID)
                seal.fulfill(wishlistCoursesIDs)
            }.catch { _ in
                switch dataSourceType {
                case .cache:
                    seal.reject(Error.cacheFetchFailed)
                case .remote:
                    seal.reject(Error.remoteFetchFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case cacheFetchFailed
        case remoteFetchFailed
    }
}
