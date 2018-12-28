//
//  UsersPersistenceService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 10/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol UsersPersistenceServiceProtocol: class {
    func fetch(
        ids: [User.IdType],
        page: Int
    ) -> Promise<([User], Meta)>
    func fetch(id: User.IdType) -> Promise<User?>
}

final class UsersPersistenceService: UsersPersistenceServiceProtocol {
    func fetch(
        ids: [User.IdType],
        page: Int = 1
    ) -> Promise<([User], Meta)> {
        return Promise { seal in
            User.fetchAsync(ids: ids).done { users in
                seal.fulfill((users, Meta.oneAndOnlyPage))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: User.IdType) -> Promise<User?> {
        return Promise { seal in
            self.fetch(ids: [id]).done { users, _ in
                seal.fulfill(users.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
