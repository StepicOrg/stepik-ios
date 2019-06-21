import Foundation
import PromiseKit

protocol AssignmentsPersistenceServiceProtocol: class {
    func fetch(ids: [Assignment.IdType]) -> Promise<[Assignment]>
}

final class AssignmentsPersistenceService: AssignmentsPersistenceServiceProtocol {
    func fetch(ids: [Assignment.IdType]) -> Promise<[Assignment]> {
        return Promise { seal in
            Assignment.fetchAsync(ids: ids).done { assignments in
                let assignments = Array(Set(assignments)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(assignments)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
