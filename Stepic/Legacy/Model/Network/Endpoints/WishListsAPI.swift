import Alamofire
import Foundation
import PromiseKit

final class WishListsAPI: APIEndpoint {
    override var name: String { "wish-lists" }

    func getWishlist(page: Int = 1) -> Promise<([WishlistEntryPlainObject], Meta)> {
        let params: Parameters = [
            "platform": PlatformType.mobile.stringValue,
            "page": page
        ]

        return self.retrieve.request(
            requestEndpoint: self.name,
            paramName: self.name,
            params: params,
            withManager: self.manager
        )
    }

    func addToWishlist(courseID: Course.IdType) -> Promise<WishlistEntryPlainObject> {
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

    func deleteFromWishlist(wishlistEntryID: WishlistEntryPlainObject.IdType) -> Promise<Void> {
        self.delete.request(requestEndpoint: self.name, deletingId: wishlistEntryID, withManager: self.manager)
    }
}
