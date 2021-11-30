import Foundation
import PromiseKit

protocol WishlistRepositoryProtocol: AnyObject {
    func fetchWishlistEntries(sourceType: DataSourceType) -> Promise<[WishlistEntryPlainObject]>

    func addCourseToWishlist(courseID: Course.IdType) -> Promise<Void>
    func deleteCourseFromWishlist(courseID: Course.IdType, sourceType: DataSourceType) -> Promise<Void>

    func deleteAllWishlistEntries() -> Promise<Void>
}

final class WishlistRepository: WishlistRepositoryProtocol {
    private let wishlistEntriesPersistenceService: WishlistEntriesPersistenceServiceProtocol
    private let wishListsNetworkService: WishListsNetworkServiceProtocol

    private let coursesPersistenceService: CoursesPersistenceServiceProtocol

    private let dataBackUpdateService: DataBackUpdateServiceProtocol

    init(
        wishlistEntriesPersistenceService: WishlistEntriesPersistenceServiceProtocol,
        wishListsNetworkService: WishListsNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        dataBackUpdateService: DataBackUpdateServiceProtocol
    ) {
        self.wishlistEntriesPersistenceService = wishlistEntriesPersistenceService
        self.wishListsNetworkService = wishListsNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.dataBackUpdateService = dataBackUpdateService
    }

    func fetchWishlistEntries(sourceType: DataSourceType) -> Promise<[WishlistEntryPlainObject]> {
        switch sourceType {
        case .cache:
            return self.wishlistEntriesPersistenceService
                .fetchAll()
                .mapValues(\.plainObject)
        case .remote:
            return self.wishListsNetworkService
                .fetchWishlistEntries()
                .map { wishlistEntries in
                    wishlistEntries.sorted { lhs, rhs in
                        (lhs.createDate ?? Date()) > (rhs.createDate ?? Date())
                    }
                }
                .then { remoteWishlistEntries in
                    self.wishlistEntriesPersistenceService
                        .saveNewWishlistEntries(remoteWishlistEntries)
                        .map { remoteWishlistEntries }
                }
        }
    }

    func addCourseToWishlist(courseID: Course.IdType) -> Promise<Void> {
        self.wishListsNetworkService
            .createWishlistEntry(courseID: courseID)
            .then { self.wishlistEntriesPersistenceService.save(wishlistEntries: [$0]) }
            .then { self.coursesPersistenceService.batchUpdateIsInWishlist(id: courseID, isInWishList: true) }
            .then { self.triggerWishlistUpdate().asVoid() }
    }

    func deleteCourseFromWishlist(courseID: Course.IdType, sourceType: DataSourceType) -> Promise<Void> {
        firstly { () -> Promise<Void> in
            if sourceType == .remote {
                return self.wishlistEntriesPersistenceService
                    .fetch(courseID: courseID)
                    .then { cachedWishlistEntry -> Promise<WishlistEntryPlainObject?> in
                        if let cachedWishlistEntry = cachedWishlistEntry {
                            return .value(cachedWishlistEntry.plainObject)
                        }
                        return self.wishListsNetworkService.fetchWishlistEntry(courseID: courseID)
                    }
                    .compactMap { $0 }
                    .then { self.wishListsNetworkService.deleteWishlistEntry(wishlistEntryID: $0.id) }
            }
            return .value(())
        }
        .then { self.wishlistEntriesPersistenceService.deleteWishlistEntry(courseID: courseID).asVoid() }
        .then { self.coursesPersistenceService.batchUpdateIsInWishlist(id: courseID, isInWishList: false) }
        .then { self.triggerWishlistUpdate().asVoid() }
    }

    func deleteAllWishlistEntries() -> Promise<Void> {
        self.wishlistEntriesPersistenceService.deleteAll()
    }

    // MARK: Private API

    private func triggerWishlistUpdate() -> Guarantee<Void> {
        self.wishlistEntriesPersistenceService.fetchAll().done { wishlistEntries in
            self.dataBackUpdateService.triggerWishlistUpdate(coursesIDs: wishlistEntries.map(\.courseID))
        }
    }
}

extension WishlistRepository {
    static var `default`: WishlistRepository {
        WishlistRepository(
            wishlistEntriesPersistenceService: WishlistEntriesPersistenceService(),
            wishListsNetworkService: WishListsNetworkService(wishListsAPI: WishListsAPI()),
            coursesPersistenceService: CoursesPersistenceService(),
            dataBackUpdateService: DataBackUpdateService.default
        )
    }
}
