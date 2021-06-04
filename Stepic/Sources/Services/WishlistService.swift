import Foundation
import PromiseKit

protocol WishlistServiceProtocol: AnyObject {
    func canAddCourseToWishlist(_ course: Course) -> Bool
    func isCourseInWishlist(_ courseID: Course.IdType) -> Bool
    func getCoursesWishlist() -> [Course.IdType]
    func removeAll()

    func syncWishlist(userID: User.IdType) -> Promise<Void>
    func addCourseToWishlist(_ courseID: Course.IdType, userID: User.IdType) -> Promise<Void>
    func removeCourseFromWishlist(_ courseID: Course.IdType, userID: User.IdType) -> Promise<Void>
}

extension WishlistServiceProtocol {
    func canAddCourseToWishlist(_ course: Course) -> Bool { !course.enrolled }

    func isCourseInWishlist(_ courseID: Course.IdType) -> Bool {
        self.getCoursesWishlist().contains(courseID)
    }

    func isCourseInWishlist(_ course: Course) -> Bool {
        self.isCourseInWishlist(course.id)
    }

    func addCourseToWishlist(_ course: Course, userID: User.IdType) -> Promise<Void> {
        self.addCourseToWishlist(course.id, userID: userID)
    }

    func removeCourseFromWishlist(_ course: Course, userID: User.IdType) -> Promise<Void> {
        self.removeCourseFromWishlist(course.id, userID: userID)
    }
}

final class WishlistService: WishlistServiceProtocol {
    private let wishlistStorageManager: WishlistStorageManagerProtocol
    private let storageRecordsNetworkService: StorageRecordsNetworkServiceProtocol

    init(
        wishlistStorageManager: WishlistStorageManagerProtocol,
        storageRecordsNetworkService: StorageRecordsNetworkServiceProtocol
    ) {
        self.wishlistStorageManager = wishlistStorageManager
        self.storageRecordsNetworkService = storageRecordsNetworkService
    }

    func getCoursesWishlist() -> [Course.IdType] {
        self.wishlistStorageManager.coursesIDs
    }

    func removeAll() {
        self.wishlistStorageManager.coursesIDs = []
    }

    func syncWishlist(userID: User.IdType) -> Promise<Void> {
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

    func addCourseToWishlist(_ courseID: Course.IdType, userID: User.IdType) -> Promise<Void> {
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

            return .value(())
        }
    }

    func removeCourseFromWishlist(_ courseID: Course.IdType, userID: User.IdType) -> Promise<Void> {
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
                // swiftlint:disable:next array_init
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

            return .value(())
        }
    }
}

extension WishlistService {
    static var `default`: WishlistService {
        WishlistService(
            wishlistStorageManager: WishlistStorageManager(),
            storageRecordsNetworkService: StorageRecordsNetworkService(storageRecordsAPI: StorageRecordsAPI())
        )
    }
}
