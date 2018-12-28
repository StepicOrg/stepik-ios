//
//  UnitsNetworkService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol UnitsNetworkServiceProtocol: class {
    func fetch(ids: [Unit.IdType]) -> Promise<[Unit]>
}

final class UnitsNetworkService: UnitsNetworkServiceProtocol {
    private let unitsAPI: UnitsAPI

    init(unitsAPI: UnitsAPI) {
        self.unitsAPI = unitsAPI
    }

    func fetch(ids: [Unit.IdType]) -> Promise<[Unit]> {
        return Promise { seal in
            self.unitsAPI.retrieve(ids: ids).done { units in
                let units = units.reordered(order: ids, transform: { $0.id })
                seal.fulfill(units)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
