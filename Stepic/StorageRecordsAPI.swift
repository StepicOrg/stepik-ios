//
//  StorageRecordsAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 23.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class StorageRecordsAPI: APIEndpoint {
    override var name: String { return "storage-records" }

    func retrieve(
        userID: User.IdType,
        kindPrefixType prefixType: StorageKind.PrefixType
    ) -> Promise<([StorageRecord], Meta)> {
        let params: Parameters = [
            StorageRecord.JSONKey.user.rawValue: userID,
            "kind__startswith": prefixType.startsWith
        ]

        return self.retrieve.request(
            requestEndpoint: self.name,
            paramName: self.name,
            params: params,
            withManager: self.manager
        )
    }

    func retrieve(userID: User.IdType, kind: StorageKind?) -> Promise<([StorageRecord], Meta)> {
        let params: Parameters = [
            StorageRecord.JSONKey.kind.rawValue: kind?.name ?? "",
            StorageRecord.JSONKey.user.rawValue: userID
        ]

        return self.retrieve.request(
            requestEndpoint: self.name,
            paramName: self.name,
            params: params,
            withManager: self.manager
        )
    }

    func delete(id: Int) -> Promise<Void> {
        return self.delete.request(requestEndpoint: self.name, deletingId: id, withManager: self.manager)
    }

    func create(record: StorageRecord) -> Promise<StorageRecord> {
        return self.create.request(
            requestEndpoint: self.name,
            paramName: "storage-record",
            creatingObject: record,
            withManager: self.manager
        )
    }

    func update(record: StorageRecord) -> Promise<StorageRecord> {
        return self.update.request(
            requestEndpoint: self.name,
            paramName: "storage-record",
            updatingObject: record,
            withManager: self.manager
        )
    }
}
