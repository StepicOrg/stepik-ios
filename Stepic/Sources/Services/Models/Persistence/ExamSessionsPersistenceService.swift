import CoreData
import Foundation
import PromiseKit

protocol ExamSessionsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [ExamSession.IdType]) -> Promise<[ExamSession]>
    func deleteAll() -> Promise<Void>
}

final class ExamSessionsPersistenceService: ExamSessionsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [ExamSession.IdType]) -> Promise<[ExamSession]> {
        Promise { seal in
            ExamSession.fetchAsync(ids: ids).done { examSessions in
                let result = Array(Set(examSessions)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            self.managedObjectContext.performAndWait {
                do {
                    let examSessions = try self.managedObjectContext.fetch(ExamSession.fetchRequest)

                    for session in examSessions {
                        self.managedObjectContext.delete(session)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("ExamSessionsPersistenceService :: failed delete all exam sessions with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case deleteFailed
    }
}
