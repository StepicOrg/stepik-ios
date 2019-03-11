//
//  UnitsPersistenceService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol UnitsPersistenceServiceProtocol: class {
    func fetch(ids: [Unit.IdType]) -> Promise<[Unit]>
    func fetch(id: Unit.IdType) -> Promise<Unit?>
}

final class UnitsPersistenceService: UnitsPersistenceServiceProtocol {
    func fetch(ids: [Unit.IdType]) -> Promise<[Unit]> {
        return Promise { seal in
            Unit.fetchAsync(ids: ids).done { units in
                let units = Array(Set(units)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(units)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: Unit.IdType) -> Promise<Unit?> {
        return Promise { seal in
            Unit.fetchAsync(ids: [id]).done { units in
                seal.fulfill(units.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
