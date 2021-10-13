import Foundation
import SwiftyJSON

final class StorageRecord: JSONSerializable {
    var id: Int = 0
    var user: Int?
    var data: StorageRecordData?
    var kind: StorageRecordKind?
    var createDate: Date?
    var updateDate: Date?

    var json: JSON {
        [
            JSONKey.id.rawValue: self.id,
            JSONKey.kind.rawValue: self.kind?.name ?? "",
            JSONKey.data.rawValue: self.data?.dictValue ?? ""
        ]
    }

    init(data: StorageRecordData, kind: StorageRecordKind?) {
        self.kind = kind
        self.data = data
    }

    required init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].int ?? 0
        self.kind = StorageRecordKind(string: json[JSONKey.kind.rawValue].stringValue)
        self.createDate = Parser.dateFromTimedateJSON(json[JSONKey.createDate.rawValue])
        self.updateDate = Parser.dateFromTimedateJSON(json[JSONKey.updateDate.rawValue])
        self.data = self.parseStorageData(from: json[JSONKey.data.rawValue], withKind: self.kind)
        self.user = json[JSONKey.user.rawValue].int
    }

    private func parseStorageData(from json: JSON, withKind kind: StorageRecordKind?) -> StorageRecordData? {
        guard let kind = kind else {
            return nil
        }

        switch kind {
        case .deadline:
            return DeadlineStorageRecordData(json: json)
        case .personalOffers:
            return PersonalOfferStorageRecordData(json: json)
        case .wishlist:
            return WishlistStorageRecordData(json: json)
        }
    }

    enum JSONKey: String {
        case id
        case kind
        case createDate = "create_date"
        case updateDate = "update_date"
        case data
        case user
    }
}
