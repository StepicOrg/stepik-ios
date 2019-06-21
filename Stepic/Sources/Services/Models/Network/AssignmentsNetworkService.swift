import Foundation
import PromiseKit

protocol AssignmentsNetworkServiceProtocol: class {
    func fetch(ids: [Assignment.IdType]) -> Promise<[Assignment]>
}

final class AssignmentsNetworkService: AssignmentsNetworkServiceProtocol {
    private let assignmentsAPI: AssignmentsAPI

    init(assignmentsAPI: AssignmentsAPI) {
        self.assignmentsAPI = assignmentsAPI
    }

    func fetch(ids: [Assignment.IdType]) -> Promise<[Assignment]> {
        return Promise { seal in
            self.assignmentsAPI.retrieve(ids: ids).done { assignments in
                let assignments = assignments.reordered(order: ids, transform: { $0.id })
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
