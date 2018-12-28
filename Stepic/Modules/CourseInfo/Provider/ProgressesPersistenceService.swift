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
        return Promise { seal in
            Progress.fetchAsync(ids: ids).done { progresses in
                seal.fulfill((progresses, Meta.oneAndOnlyPage))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: Progress.IdType) -> Promise<Progress?> {
        return Promise { seal in
            self.fetch(ids: [id]).done { progresses, _ in
                seal.fulfill(progresses.first)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
