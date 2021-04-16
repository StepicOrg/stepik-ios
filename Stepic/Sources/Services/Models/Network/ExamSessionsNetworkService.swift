import Foundation
import PromiseKit

protocol ExamSessionsNetworkServiceProtocol: AnyObject {
    func fetch(ids: [ExamSession.IdType]) -> Promise<[ExamSession]>
}

extension ExamSessionsNetworkServiceProtocol {
    func fetch(id: ExamSession.IdType) -> Promise<ExamSession?> {
        self.fetch(ids: [id]).map(\.first)
    }
}

final class ExamSessionsNetworkService: ExamSessionsNetworkServiceProtocol {
    private let examSessionsAPI: ExamSessionsAPI

    init(examSessionsAPI: ExamSessionsAPI) {
        self.examSessionsAPI = examSessionsAPI
    }

    func fetch(ids: [ExamSession.IdType]) -> Promise<[ExamSession]> {
        self.examSessionsAPI.get(ids: ids)
    }
}
