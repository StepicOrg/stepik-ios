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
    private static let createUpdateParamName = "storage-record"

    override var name: String { "storage-records" }

    func retrieve(
        userID: User.IdType,
        kindPrefixType prefixType: StorageRecordKind.PrefixType
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

    func retrieve(userID: User.IdType, kind: StorageRecordKind?) -> Promise<([StorageRecord], Meta)> {
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
        self.delete.request(requestEndpoint: self.name, deletingId: id, withManager: self.manager)
    }

    func create(record: StorageRecord) -> Promise<StorageRecord> {
        self.create.request(
            requestEndpoint: self.name,
            paramName: Self.createUpdateParamName,
            creatingObject: record,
            withManager: self.manager
        )
    }

    func update(record: StorageRecord) -> Promise<StorageRecord> {
        self.update.request(
            requestEndpoint: self.name,
            paramName: Self.createUpdateParamName,
            updatingObject: record,
            withManager: self.manager
        )
    }
}
