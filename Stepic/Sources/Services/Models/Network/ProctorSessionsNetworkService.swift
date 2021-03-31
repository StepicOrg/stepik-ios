import Foundation
import PromiseKit

protocol ProctorSessionsNetworkServiceProtocol: AnyObject {
    func fetch(ids: [ProctorSession.IdType]) -> Promise<[ProctorSession]>
}

extension ProctorSessionsNetworkServiceProtocol {
    func fetch(id: ProctorSession.IdType) -> Promise<ProctorSession?> {
        self.fetch(ids: [id]).map(\.first)
    }
}

final class ProctorSessionsNetworkService: ProctorSessionsNetworkServiceProtocol {
    private let proctorSessionsAPI: ProctorSessionsAPI

    init(proctorSessionsAPI: ProctorSessionsAPI) {
        self.proctorSessionsAPI = proctorSessionsAPI
    }

    func fetch(ids: [ProctorSession.IdType]) -> Promise<[ProctorSession]> {
        self.proctorSessionsAPI.get(ids: ids)
    }
}
