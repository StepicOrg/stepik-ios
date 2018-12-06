//
//  ProgressesPersistenceService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 04.12.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol ProgressesPersistenceServiceProtocol: class {
    func fetch(
        ids: [Progress.IdType],
        page: Int
    ) -> Promise<([Progress], Meta)>
    func fetch(id: Progress.IdType) -> Promise<Progress?>
}

final class ProgressesPersistenceService: ProgressesPersistenceServiceProtocol {
    func fetch(
        ids: [Progress.IdType],
        page: Int = 1
    ) -> Promise<([Progress], Meta)> {
        fatalError("Not implemented yet")
    }

    func fetch(id: Progress.IdType) -> Promise<Progress?> {
        return Promise { seal in
            Progress.fetchAsync(ids: [id]).done { progresses in
                seal.fulfill(progresses.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
