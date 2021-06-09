import Foundation
import PromiseKit

protocol WishlistWidgetProviderProtocol {
    func fetchWishlistCoursesIDs(from dataSourceType: DataSourceType) -> Promise<[Course.IdType]>
}

final class WishlistWidgetProvider: WishlistWidgetProviderProtocol {
    private let wishlistService: WishlistServiceProtocol
    private let userAccountService: UserAccountServiceProtocol

    init(
        wishlistService: WishlistServiceProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.wishlistService = wishlistService
        self.userAccountService = userAccountService
    }

    func fetchWishlistCoursesIDs(from dataSourceType: DataSourceType) -> Promise<[Course.IdType]> {
        guard let currentUserID = self.userAccountService.currentUserID else {
            switch dataSourceType {
            case .cache:
                return Promise(error: Error.cacheFetchFailed)
            case .remote:
                return Promise(error: Error.remoteFetchFailed)
            }
        }

        switch dataSourceType {
        case .cache:
            return .value(self.wishlistService.getWishlist())
        case .remote:
            return Promise { seal in
                self.wishlistService.fetchWishlist(userID: currentUserID).done {
                    let coursesIDs = self.wishlistService.getWishlist()
                    seal.fulfill(coursesIDs)
                }.catch { _ in
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
