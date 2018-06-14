//
//  StorageRecordsAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 23.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class StorageRecordsAPI: APIEndpoint {
    override var name: String { return "storage-records" }

    func retrieve(kind: StorageKind?, user: Int) -> Promise<([StorageRecord], Meta)> {
        let params: Parameters = [
            "kind": kind?.getName() ?? "",
            "user": user
        ]
        return retrieve.request(requestEndpoint: "storage-records", paramName: "storage-records", params: params, withManager: manager)
    }

    func delete(id: Int) -> Promise<Void> {
        return delete.request(requestEndpoint: "storage-records", deletingId: id, withManager: manager)
    }

    func create(record: StorageRecord) -> Promise<StorageRecord> {
        return create.request(requestEndpoint: "storage-records", paramName: "storage-record", creatingObject: record, withManager: manager)
    }

    func update(record: StorageRecord) -> Promise<StorageRecord> {
        return update.request(requestEndpoint: "storage-records", paramName: "storage-record", updatingObject: record, withManager: manager)
    }
}
