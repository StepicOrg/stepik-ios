import Alamofire
import Foundation
import PromiseKit

final class WishListsAPI: APIEndpoint {
    override var name: String { "wish-lists" }

    func retrieveWishlist(page: Int = 1) -> Promise<([WishlistEntryPlainObject], Meta)> {
        self.retrieve.request(
            requestEndpoint: self.name,
            paramName: self.name,
            params: ["page": page],
            withManager: self.manager
        )
    }

    func retrieveAllWishlistPages() -> Promise<[WishlistEntryPlainObject]> {
        self.retrieve.requestWithCollectAllPages(
            requestEndpoint: self.name,
            paramName: self.name,
            params: [:],
            withManager: self.manager
        )
    }

    func createWishlistEntry(courseID: Course.IdType) -> Promise<WishlistEntryPlainObject> {
        let wishlistEntryToAdd = WishlistEntryPlainObject(
            id: -1,
            courseID: courseID,
            userID: -1,
            createDate: nil,
            platform: PlatformType.mobile.stringValue
        )

        return self.create.request(
            requestEndpoint: self.name,
            paramName: "wish-list",
            creatingObject: wishlistEntryToAdd,
            withManager: self.manager
        ).compactMap { _, json -> WishlistEntryPlainObject? in
            if let createdObjectJSON = json[self.name].arrayValue.first {
                return WishlistEntryPlainObject(json: createdObjectJSON)
            }
            return nil
        }
    }

    func deleteWishlistEntry(wishlistEntryID: WishlistEntryPlainObject.IdType) -> Promise<Void> {
        self.delete.request(requestEndpoint: self.name, deletingId: wishlistEntryID, withManager: self.manager)
    }
}
