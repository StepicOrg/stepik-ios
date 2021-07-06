import CoreData
import Foundation
import PromiseKit

protocol CourseBenefitByMonthsPersistenceServiceProtocol: AnyObject {
    func fetch(id: CourseBenefitByMonth.IdType) -> Guarantee<[CourseBenefitByMonth]>
    func fetch(ids: [CourseBenefitByMonth.IdType]) -> Guarantee<[CourseBenefitByMonth]>
    func fetch(userID: User.IdType) -> Guarantee<[CourseBenefitByMonth]>
    func fetch(courseID: Course.IdType) -> Guarantee<[CourseBenefitByMonth]>
    func fetchAll() -> Guarantee<[CourseBenefitByMonth]>
    func deleteAll() -> Promise<Void>
}

extension CourseBenefitByMonthsPersistenceServiceProtocol {
    func fetch(id: CourseBenefitByMonth.IdType) -> Guarantee<CourseBenefitByMonth?> {
        self.fetch(id: id).map(\.first)
    }
}

final class CourseBenefitByMonthsPersistenceService: CourseBenefitByMonthsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(id: CourseBenefitByMonth.IdType) -> Guarantee<[CourseBenefitByMonth]> {
        Guarantee { seal in
            let fetchRequest = CourseBenefitByMonth.fetchRequest
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CourseBenefitByMonth.managedId),
                id
            )
            fetchRequest.sortDescriptors = CourseBenefitByMonth.defaultSortDescriptors

            do {
                let courseBenefitByMonths = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBenefitByMonths)
            } catch {
                print("CourseBenefitByMonthsPersistenceService :: failed fetch by id = \(id)")
                seal([])
            }
        }
    }

    func fetch(ids: [CourseBenefitByMonth.IdType]) -> Guarantee<[CourseBenefitByMonth]> {
        Guarantee { seal in
            let fetchRequest = CourseBenefitByMonth.fetchRequest
            let idSubpredicates = ids.map { id in
                NSPredicate(
                    format: "%K == %@",
                    #keyPath(CourseBenefitByMonth.managedId),
                    id
                )
            }
            let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idSubpredicates)

            fetchRequest.predicate = compoundPredicate
            fetchRequest.sortDescriptors = CourseBenefitByMonth.defaultSortDescriptors

            do {
                let courseBenefitByMonths = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBenefitByMonths)
            } catch {
                print("CourseBenefitByMonthsPersistenceService :: failed fetch by ids = \(ids)")
                seal([])
            }
        }
    }

    func fetch(userID: User.IdType) -> Guarantee<[CourseBenefitByMonth]> {
        Guarantee { seal in
            let fetchRequest = CourseBenefitByMonth.fetchRequest
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CourseBenefitByMonth.managedUserId),
                NSNumber(value: userID)
            )
            fetchRequest.sortDescriptors = CourseBenefitByMonth.defaultSortDescriptors

            do {
                let courseBenefitByMonths = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBenefitByMonths)
            } catch {
                print("CourseBenefitByMonthsPersistenceService :: failed fetch by user id = \(userID)")
                seal([])
            }
        }
    }

    func fetch(courseID: Course.IdType) -> Guarantee<[CourseBenefitByMonth]> {
        Guarantee { seal in
            let fetchRequest = CourseBenefitByMonth.fetchRequest
            fetchRequest.predicate = NSPredicate(
                format: "%K ENDSWITH %@",
                #keyPath(CourseBenefitByMonth.managedId),
                "-\(courseID)"
            )
            fetchRequest.sortDescriptors = CourseBenefitByMonth.defaultSortDescriptors

            do {
                let courseBenefitByMonths = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBenefitByMonths)
            } catch {
                print("CourseBenefitByMonthsPersistenceService :: failed fetch by course id = \(courseID)")
                seal([])
            }
        }
    }

    func fetchAll() -> Guarantee<[CourseBenefitByMonth]> {
        Guarantee { seal in
            let fetchRequest = CourseBenefitByMonth.fetchRequest
            fetchRequest.sortDescriptors = CourseBenefitByMonth.defaultSortDescriptors

            do {
                let courseBenefitByMonths = try self.managedObjectContext.fetch(fetchRequest)
                seal(courseBenefitByMonths)
            } catch {
                print("CourseBenefitByMonthsPersistenceService :: failed fetch all")
                seal([])
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CourseBenefitByMonth")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            self.managedObjectContext.performAndWait {
                do {
                    try self.managedObjectContext.executeAndMergeChanges(using: batchDeleteRequest)
                    try? self.managedObjectContext.save()
                    seal.fulfill(())
                } catch {
                    print("CourseBenefitByMonthsPersistenceService :: failed delete all with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
