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

    init?(string: String) {
        if string.hasPrefix("deadline_") {
            let courseIDString = String(string.dropFirst(9))
            if let courseID = Int(courseIDString) {
                self = .deadline(courseID: courseID)
                return
            }
        }
        return nil
    }

    func getName() -> String {
        switch self {
        case .deadline(courseID: let courseID):
            return "deadline_\(courseID)"
        }
    }
}

class StorageRecord: JSONSerializable {

    var id: Int = 0
    var user: Int?
    var data: StorageData?
    var kind: StorageKind?
    var createDate: Date?
    var updateDate: Date?

    init(data: StorageData, kind: StorageKind?) {
        self.kind = kind
        self.data = data
    }

    required init(json: JSON) {
        update(json: json)
    }

    func update(json: JSON) {
        id = json["id"].int ?? 0
        kind = StorageKind(string: json["kind"].stringValue)
        createDate = Parser.sharedParser.dateFromTimedateJSON(json["create_date"])
        updateDate = Parser.sharedParser.dateFromTimedateJSON(json["update_date"])
        data = getStorageData(from: json["data"], withKind: kind)
        user = json["user"].int
    }

    var json: JSON {
        return [
            "id": id,
            "kind": kind?.getName() ?? "",
            "data": data?.dictValue ?? ""
        ]
    }

    private func getStorageData(from json: JSON, withKind kind: StorageKind?) -> StorageData? {
        guard let kind = kind else {
            return nil
        }

        switch kind {
        case .deadline(courseID: _):
            return DeadlineStorageData(json: json)
        }
    }
}
