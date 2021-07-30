import CoreData
import PromiseKit

protocol CourseBenefitsPersistenceServiceProtocol: AnyObject {
    func fetch(id: CourseBenefit.IdType) -> Guarantee<CourseBenefit?>
    func fetch(ids: [CourseBenefit.IdType]) -> Guarantee<[CourseBenefit]>
    func fetch(courseID: Course.IdType) -> Guarantee<[CourseBenefit]>
    func fetchAll() -> Guarantee<[CourseBenefit]>

    func deleteAll() -> Promise<Void>
}

final class CourseBenefitsPersistenceService: BasePersistenceService<CourseBenefit>,
                                              CourseBenefitsPersistenceServiceProtocol {
    func fetch(courseID: Course.IdType) -> Guarantee<[CourseBenefit]> {
        Guarantee { seal in
            let request = CourseBenefit.sortedFetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CourseBenefit.managedCourseId),
                NSNumber(value: courseID)
            )

            do {
                let courseBenefits = try self.managedObjectContext.fetch(request)
                seal(courseBenefits)
            } catch {
                print("CourseBenefitsPersistenceService :: failed fetch by course id = \(courseID)")
                seal([])
            }
        }
    }
}
