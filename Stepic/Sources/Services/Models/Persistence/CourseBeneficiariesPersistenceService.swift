import CoreData
import Foundation
import PromiseKit

protocol CourseBeneficiariesPersistenceServiceProtocol: AnyObject {
    func fetch(courseID: Course.IdType, userID: User.IdType) -> Guarantee<[CourseBeneficiary]>
    func fetchAll() -> Guarantee<[CourseBeneficiary]>
    func deleteAll() -> Promise<Void>
}

extension CourseBeneficiariesPersistenceServiceProtocol {
    func fetch(courseID: Course.IdType, userID: User.IdType) -> Guarantee<CourseBeneficiary?> {
        self.fetch(courseID: courseID, userID: userID).map(\.first)
    }
}

final class CourseBeneficiariesPersistenceService: CourseBeneficiariesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(courseID: Course.IdType, userID: User.IdType) -> Guarantee<[CourseBeneficiary]> {
        Guarantee { seal in
            let coursePredicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CourseBeneficiary.managedCourseId),
                NSNumber(value: courseID)
            )
            let userPredicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CourseBeneficiary.managedUserId),
                NSNumber(value: userID)
            )
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [coursePredicate, userPredicate])

            let fetchRequest = CourseBeneficiary.fetchRequest
            fetchRequest.predicate = compoundPredicate
            fetchRequest.sortDescriptors = CourseBeneficiary.defaultSortDescriptors

            do {
                let courseBeneficiaries = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBeneficiaries)
            } catch {
                print("CourseBeneficiariesPersistenceService :: failed fetch with error = \(error)")
                seal([])
            }
        }
    }

    func fetchAll() -> Guarantee<[CourseBeneficiary]> {
        Guarantee { seal in
            let fetchRequest = CourseBeneficiary.fetchRequest
            fetchRequest.sortDescriptors = CourseBeneficiary.defaultSortDescriptors

            do {
                let courseBeneficiaries = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBeneficiaries)
            } catch {
                print("CourseBeneficiariesPersistenceService :: failed fetch all")
                seal([])
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CourseBeneficiary")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            self.managedObjectContext.performAndWait {
                do {
                    try self.managedObjectContext.executeAndMergeChanges(using: batchDeleteRequest)
                    try? self.managedObjectContext.save()
                    seal.fulfill(())
                } catch {
                    print("CourseBeneficiariesPersistenceService :: failed delete all with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
