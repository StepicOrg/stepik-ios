import Foundation
import PromiseKit
import StepikModel

final class WishListsAPI: APIEndpoint {
    override class var name: String { "wish-lists" }

    func retrieveWishlistEntry(courseID: Course.IdType) -> Promise<WishlistEntry?> {
        self.retrieve
            .requestDecodableObjects(
                requestEndpoint: Self.name,
                params: [JSONKey.course.rawValue: courseID],
                withManager: self.manager
            )
            .map { $0.decodedObjects.first }
    }

    func retrieveAllWishlistPages() -> Promise<[WishlistEntry]> {
        self.retrieve.requestDecodableObjectsWithCollectAllPages(requestEndpoint: Self.name, withManager: self.manager)
    }

    func createWishlistEntry(courseID: Course.IdType) -> Promise<WishlistEntry> {
        let body = [
            JSONKey.wishList.rawValue: [
                JSONKey.course.rawValue: courseID,
                JSONKey.platform.rawValue: PlatformType.mobile.stringValue
            ]
        ]

        return self.create
            .requestDecodableObjects(requestEndpoint: Self.name, bodyJSONObject: body, withManager: self.manager)
            .compactMap { $0.decodedObjects.first }
    }

    func deleteWishlistEntry(wishlistEntryID: Int) -> Promise<Void> {
        self.delete.request(requestEndpoint: Self.name, deletingId: wishlistEntryID, withManager: self.manager)
    }

    private enum JSONKey: String {
        case course
        case platform
        case wishList = "wish-list"
    }
}
