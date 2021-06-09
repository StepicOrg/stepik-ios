import Foundation
import PromiseKit

protocol StorageRecordsNetworkServiceProtocol: AnyObject {
    func fetch(
        userID: User.IdType,
        kindPrefixType: StorageRecordKind.PrefixType
    ) -> Promise<([StorageRecord], Meta)>
    func fetchWithSortingByUpdateDateDesc(
        userID: User.IdType,
        kindPrefixType: StorageRecordKind.PrefixType
    ) -> Promise<([StorageRecord], Meta)>
    func fetchWithSortingByUpdateDateDesc(
        userID: User.IdType,
        kind: StorageRecordKind
    ) -> Promise<([StorageRecord], Meta)>
    func fetch(userID: User.IdType, kind: StorageRecordKind) -> Promise<([StorageRecord], Meta)>
    func delete(id: StorageRecord.IdType) -> Promise<Void>
    func create(record: StorageRecord) -> Promise<StorageRecord>
    func update(record: StorageRecord) -> Promise<StorageRecord>
}

final class StorageRecordsNetworkService: StorageRecordsNetworkServiceProtocol {
    private let storageRecordsAPI: StorageRecordsAPI

    init(storageRecordsAPI: StorageRecordsAPI) {
        self.storageRecordsAPI = storageRecordsAPI
    }

    func fetch(
        userID: User.IdType,
        kindPrefixType: StorageRecordKind.PrefixType
    ) -> Promise<([StorageRecord], Meta)> {
        self.storageRecordsAPI.retrieve(userID: userID, kindPrefixType: kindPrefixType)
    }

    func fetchWithSortingByUpdateDateDesc(
        userID: User.IdType,
        kindPrefixType: StorageRecordKind.PrefixType
    ) -> Promise<([StorageRecord], Meta)> {
        self.storageRecordsAPI.retrieve(userID: userID, kindPrefixType: kindPrefixType, order: .updateDateDesc)
    }

    func fetch(userID: User.IdType, kind: StorageRecordKind) -> Promise<([StorageRecord], Meta)> {
        self.storageRecordsAPI.retrieve(userID: userID, kind: kind)
    }

    func fetchWithSortingByUpdateDateDesc(
        userID: User.IdType,
        kind: StorageRecordKind
    ) -> Promise<([StorageRecord], Meta)> {
        self.storageRecordsAPI.retrieve(userID: userID, kind: kind, order: .updateDateDesc)
    }

    func delete(id: StorageRecord.IdType) -> Promise<Void> {
        self.storageRecordsAPI.delete(id: id)
    }

    func create(record: StorageRecord) -> Promise<StorageRecord> {
        self.storageRecordsAPI.create(record: record)
    }

    func update(record: StorageRecord) -> Promise<StorageRecord> {
        self.storageRecordsAPI.update(record: record)
    }
}
