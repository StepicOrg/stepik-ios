import Foundation
import PromiseKit

protocol UsersNetworkServiceProtocol: class {
    func fetch(ids: [User.IdType]) -> Promise<[User]>
    func fetch(id: User.IdType) -> Promise<User?>
}

final class UsersNetworkService: UsersNetworkServiceProtocol {
    private let usersAPI: UsersAPI

    init(usersAPI: UsersAPI) {
        self.usersAPI = usersAPI
    }

    func fetch(ids: [User.IdType]) -> Promise<[User]> {
        return Promise { seal in
            self.usersAPI.retrieve(ids: ids).done { users in
                let users = users.reordered(order: ids, transform: { $0.id })
                seal.fulfill(users)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: User.IdType) -> Promise<User?> {
        return Promise { seal in
            self.fetch(ids: [id]).done { users in
                seal.fulfill(users.first)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
