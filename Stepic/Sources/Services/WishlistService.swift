import Foundation
import PromiseKit

protocol WishlistServiceProtocol: AnyObject {
    func canAdd(_ course: Course) -> Bool
    func contains(_ courseID: Course.IdType) -> Bool
    func getWishlist() -> [Course.IdType]
    func removeAll()

    func fetchWishlist(userID: User.IdType) -> Promise<Void>
    func add(_ courseID: Course.IdType, userID: User.IdType) -> Promise<Void>
    func remove(_ courseID: Course.IdType, userID: User.IdType) -> Promise<Void>
}

extension WishlistServiceProtocol {
    func canAdd(_ course: Course) -> Bool { !course.enrolled }

    func contains(_ courseID: Course.IdType) -> Bool { self.getWishlist().contains(courseID) }

    func contains(_ course: Course) -> Bool { self.contains(course.id) }

    func add(_ course: Course, userID: User.IdType) -> Promise<Void> { self.add(course.id, userID: userID) }

    func remove(_ course: Course, userID: User.IdType) -> Promise<Void> { self.remove(course.id, userID: userID) }
}

final class WishlistService: WishlistServiceProtocol {
    private let wishlistStorageManager: WishlistStorageManagerProtocol
    private let storageRecordsNetworkService: StorageRecordsNetworkServiceProtocol

    private let dataBackUpdateService: DataBackUpdateServiceProtocol

    init(
        wishlistStorageManager: WishlistStorageManagerProtocol,
        storageRecordsNetworkService: StorageRecordsNetworkServiceProtocol,
        dataBackUpdateService: DataBackUpdateServiceProtocol
    ) {
        self.wishlistStorageManager = wishlistStorageManager
        self.storageRecordsNetworkService = storageRecordsNetworkService
        self.dataBackUpdateService = dataBackUpdateService
    }

    func getWishlist() -> [Course.IdType] {
        self.wishlistStorageManager.coursesIDs
    }

    func removeAll() {
        self.wishlistStorageManager.coursesIDs = []
    }

    func fetchWishlist(userID: User.IdType) -> Promise<Void> {
        self.storageRecordsNetworkService.fetch(
            userID: userID,
            kind: .wishlist
        ).done { storageRecords, _ in
            if let storageRecord = storageRecords.first,
               case .wishlist = storageRecord.kind,
               let wishlistData = storageRecord.data as? WishlistStorageRecordData {
                self.wishlistStorageManager.coursesIDs = wishlistData.coursesIDs
            } else {
                self.wishlistStorageManager.coursesIDs = []
            }
        }
    }

    func add(_ courseID: Course.IdType, userID: User.IdType) -> Promise<Void> {
        if self.wishlistStorageManager.coursesIDs.contains(courseID) {
            return .value(())
        }

        return self.storageRecordsNetworkService.fetch(
            userID: userID,
            kind: .wishlist
        ).then { storageRecords, _ -> Promise<StorageRecord> in
            if let storageRecord = storageRecords.first,
               case .wishlist = storageRecord.kind,
               let wishlistData = storageRecord.data as? WishlistStorageRecordData {
                if !wishlistData.coursesIDs.contains(courseID) {
                    wishlistData.coursesIDs.append(courseID)
                }

                return self.storageRecordsNetworkService.update(record: storageRecord)
            } else {
                let storageRecord = StorageRecord(
                    data: WishlistStorageRecordData(coursesIDs: [courseID]),
                    kind: .wishlist
                )

                return self.storageRecordsNetworkService.create(record: storageRecord)
            }
        }.then { storageRecord -> Promise<Void> in
            if let wishlistData = storageRecord.data as? WishlistStorageRecordData {
                self.wishlistStorageManager.coursesIDs = wishlistData.coursesIDs
            }

            self.dataBackUpdateService.triggerWishlistUpdate(coursesIDs: self.wishlistStorageManager.coursesIDs)

            return .value(())
        }
    }

    func remove(_ courseID: Course.IdType, userID: User.IdType) -> Promise<Void> {
        if !self.wishlistStorageManager.coursesIDs.contains(courseID) {
            return .value(())
        }

        return self.storageRecordsNetworkService.fetch(
            userID: userID,
            kind: .wishlist
        ).then { storageRecords, _ -> Promise<StorageRecord?> in
            if let storageRecord = storageRecords.first,
               case .wishlist = storageRecord.kind,
               let wishlistData = storageRecord.data as? WishlistStorageRecordData {
                wishlistData.coursesIDs = wishlistData.coursesIDs.filter { $0 != courseID }
                return self.storageRecordsNetworkService.update(record: storageRecord).map { $0 }
            } else {
                return .value(nil)
            }
        }.then { storageRecordOrNil -> Promise<Void> in
            if let storageRecord = storageRecordOrNil,
               let wishlistData = storageRecord.data as? WishlistStorageRecordData {
                self.wishlistStorageManager.coursesIDs = wishlistData.coursesIDs
            } else {
                self.wishlistStorageManager.coursesIDs =
                    self.wishlistStorageManager.coursesIDs.filter { $0 != courseID }
            }

            self.dataBackUpdateService.triggerWishlistUpdate(coursesIDs: self.wishlistStorageManager.coursesIDs)

            return .value(())
        }
    }
}

extension WishlistService {
    static var `default`: WishlistService {
        WishlistService(
            wishlistStorageManager: WishlistStorageManager(),
            storageRecordsNetworkService: StorageRecordsNetworkService(storageRecordsAPI: StorageRecordsAPI()),
            dataBackUpdateService: DataBackUpdateService.default
        )
    }
}
