import Foundation
import PromiseKit

protocol PersonalOffersServiceProtocol: AnyObject {
    func syncPersonalOffers(userID: User.IdType) -> Promise<Void>
}

final class PersonalOffersService: PersonalOffersServiceProtocol {
    private let storageRecordsNetworkService: StorageRecordsNetworkServiceProtocol

    init(storageRecordsNetworkService: StorageRecordsNetworkServiceProtocol) {
        self.storageRecordsNetworkService = storageRecordsNetworkService
    }

    func syncPersonalOffers(userID: User.IdType) -> Promise<Void> {
        self.storageRecordsNetworkService.fetch(
            userID: userID,
            kindPrefixType: .personalOffers
        ).then { storageRecords, _ -> Promise<StorageRecord> in
            if let storageRecord = storageRecords.first {
                return .value(storageRecord)
            } else {
                let personalOffersRecord = StorageRecord(
                    data: PersonalOfferStorageRecordData(promoStories: []),
                    kind: .personalOffers
                )

                return self.storageRecordsNetworkService.create(record: personalOffersRecord)
            }
        }.asVoid()
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
