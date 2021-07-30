import CoreData
import PromiseKit

protocol ExamSessionsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [ExamSession.IdType]) -> Promise<[ExamSession]>
    func deleteAll() -> Promise<Void>
}

final class ExamSessionsPersistenceService: BasePersistenceService<ExamSession>,
                                            ExamSessionsPersistenceServiceProtocol {
    func fetch(ids: [ExamSession.IdType]) -> Promise<[ExamSession]> {
        firstly { () -> Guarantee<[ExamSession]> in
            self.fetch(ids: ids)
        }.map { $0.reordered(order: ids, transform: { $0.id }) }
    }
}
