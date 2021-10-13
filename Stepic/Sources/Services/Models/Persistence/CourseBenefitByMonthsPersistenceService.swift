import CoreData
import PromiseKit

protocol CourseBenefitByMonthsPersistenceServiceProtocol: AnyObject {
    func fetch(id: CourseBenefitByMonth.IdType) -> Guarantee<CourseBenefitByMonth?>
    func fetch(ids: [CourseBenefitByMonth.IdType]) -> Guarantee<[CourseBenefitByMonth]>
    func fetch(userID: User.IdType) -> Guarantee<[CourseBenefitByMonth]>
    func fetch(courseID: Course.IdType) -> Guarantee<[CourseBenefitByMonth]>
    func fetchAll() -> Guarantee<[CourseBenefitByMonth]>

    func deleteAll() -> Promise<Void>
}

final class CourseBenefitByMonthsPersistenceService: BasePersistenceService<CourseBenefitByMonth>,
                                                     CourseBenefitByMonthsPersistenceServiceProtocol {
    func fetch(userID: User.IdType) -> Guarantee<[CourseBenefitByMonth]> {
        Guarantee { seal in
            let request = CourseBenefitByMonth.sortedFetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CourseBenefitByMonth.managedUserId),
                NSNumber(value: userID)
            )
            request.returnsObjectsAsFaults = false

            do {
                let courseBenefitByMonths = try self.managedObjectContext.fetch(request)
                seal(courseBenefitByMonths)
            } catch {
                print("CourseBenefitByMonthsPersistenceService :: failed fetch by user id = \(userID)")
                seal([])
            }
        }
    }

    func fetch(courseID: Course.IdType) -> Guarantee<[CourseBenefitByMonth]> {
        Guarantee { seal in
            let request = CourseBenefitByMonth.sortedFetchRequest
            request.predicate = NSPredicate(
                format: "%K ENDSWITH %@",
                #keyPath(CourseBenefitByMonth.managedId),
                "-\(courseID)"
            )
            request.returnsObjectsAsFaults = false

            do {
                let courseBenefitByMonths = try self.managedObjectContext.fetch(request)
                seal(courseBenefitByMonths)
            } catch {
                print("CourseBenefitByMonthsPersistenceService :: failed fetch by course id = \(courseID)")
                seal([])
            }
        }
    }
}
