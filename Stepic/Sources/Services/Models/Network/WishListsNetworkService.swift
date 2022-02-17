import Foundation
import PromiseKit
import StepikModel

protocol WishListsNetworkServiceProtocol: AnyObject {
    func fetchWishlistEntry(courseID: Course.IdType) -> Promise<WishlistEntry?>
    func fetchWishlistEntries() -> Promise<[WishlistEntry]>

    func createWishlistEntry(courseID: Course.IdType) -> Promise<WishlistEntry>

    func deleteWishlistEntry(wishlistEntryID: Int) -> Promise<Void>
}

final class WishListsNetworkService: WishListsNetworkServiceProtocol {
    private let wishListsAPI: WishListsAPI

    init(wishListsAPI: WishListsAPI) {
        self.wishListsAPI = wishListsAPI
    }

    func fetchWishlistEntry(courseID: Course.IdType) -> Promise<WishlistEntry?> {
        self.wishListsAPI.retrieveWishlistEntry(courseID: courseID)
    }

    func fetchWishlistEntries() -> Promise<[WishlistEntry]> {
        self.wishListsAPI.retrieveAllWishlistPages()
    }

    func createWishlistEntry(courseID: Course.IdType) -> Promise<WishlistEntry> {
        self.wishListsAPI.createWishlistEntry(courseID: courseID)
    }

    func deleteWishlistEntry(wishlistEntryID: Int) -> Promise<Void> {
        self.wishListsAPI.deleteWishlistEntry(wishlistEntryID: wishlistEntryID)
    }
}
