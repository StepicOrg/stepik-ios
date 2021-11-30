import Foundation
import PromiseKit

protocol WishListsNetworkServiceProtocol: AnyObject {
    func fetchWishlistEntries() -> Promise<[WishlistEntryPlainObject]>

    func createWishlistEntry(courseID: Course.IdType) -> Promise<WishlistEntryPlainObject>

    func deleteWishlistEntry(wishlistEntryID: WishlistEntryPlainObject.IdType) -> Promise<Void>
}

final class WishListsNetworkService: WishListsNetworkServiceProtocol {
    private let wishListsAPI: WishListsAPI

    init(wishListsAPI: WishListsAPI) {
        self.wishListsAPI = wishListsAPI
    }

    func fetchWishlistEntries() -> Promise<[WishlistEntryPlainObject]> {
        self.wishListsAPI.retrieveAllWishlistPages()
    }

    func createWishlistEntry(courseID: Course.IdType) -> Promise<WishlistEntryPlainObject> {
        self.wishListsAPI.createWishlistEntry(courseID: courseID)
    }

    func deleteWishlistEntry(wishlistEntryID: WishlistEntryPlainObject.IdType) -> Promise<Void> {
        self.wishListsAPI.deleteWishlistEntry(wishlistEntryID: wishlistEntryID)
    }
}
