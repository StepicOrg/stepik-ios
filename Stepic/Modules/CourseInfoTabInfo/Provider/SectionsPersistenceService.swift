//
//  SectionsPersistenceService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol SectionsPersistenceServiceProtocol: class {
    func fetch(ids: [Section.IdType]) -> Promise<[Section]>
}

final class SectionsPersistenceService: SectionsPersistenceServiceProtocol {
    func fetch(ids: [Section.IdType]) -> Promise<[Section]> {
        return Promise { seal in
            Section.fetchAsync(ids: ids).done { sections in
                let sections = Array(Set(sections)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(sections)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
