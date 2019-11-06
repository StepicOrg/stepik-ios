//
//  StorageRecord.swift
//  Stepic
//
//  Created by Ostrenkiy on 23.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

enum StorageKind {
    case deadline(courseID: Int)

    var name: String {
        switch self {
        case .deadline(let courseID):
            return "deadline_\(courseID)"
        }
    }

    var prefix: PrefixType {
        switch self {
        case .deadline:
            return .deadline
        }
    }

    init?(string: String) {
        if string.hasPrefix(PrefixType.deadline.prefix) {
            let courseIDString = String(string.dropFirst(PrefixType.deadline.prefix.count))
            if let courseID = Int(courseIDString) {
                self = .deadline(courseID: courseID)
                return
            }
        }
        return nil
    }

    enum PrefixType: String {
        case deadline

        var prefix: String {
            switch self {
            case .deadline:
                return "deadline_"
            }
        }

        var startsWith: String {
            switch self {
            case .deadline:
                return "deadline"
            }
        }
    }
}

final class StorageRecord: JSONSerializable {
    var id: Int = 0
    var user: Int?
    var data: StorageData?
    var kind: StorageKind?
    var createDate: Date?
    var updateDate: Date?

    var json: JSON {
        return [
            JSONKey.id.rawValue: self.id,
            JSONKey.kind.rawValue: self.kind?.name ?? "",
            JSONKey.data.rawValue: self.data?.dictValue ?? ""
        ]
    }

    init(data: StorageData, kind: StorageKind?) {
        self.kind = kind
        self.data = data
    }

    required init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].int ?? 0
        self.kind = StorageKind(string: json[JSONKey.kind.rawValue].stringValue)
        self.createDate = Parser.shared.dateFromTimedateJSON(json[JSONKey.createDate.rawValue])
        self.updateDate = Parser.shared.dateFromTimedateJSON(json[JSONKey.updateDate.rawValue])
        self.data = self.getStorageData(from: json[JSONKey.data.rawValue], withKind: self.kind)
        self.user = json[JSONKey.user.rawValue].int
    }

    private func getStorageData(from json: JSON, withKind kind: StorageKind?) -> StorageData? {
        guard let kind = kind else {
            return nil
        }

        switch kind {
        case .deadline:
            return DeadlineStorageData(json: json)
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
