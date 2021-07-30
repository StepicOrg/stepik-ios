import CoreData
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

final class CourseBeneficiariesPersistenceService: BasePersistenceService<CourseBeneficiary>,
                                                   CourseBeneficiariesPersistenceServiceProtocol {
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

            let request = CourseBeneficiary.sortedFetchRequest(with: compoundPredicate)
            request.returnsObjectsAsFaults = false

            do {
                let courseBeneficiaries = try self.managedObjectContext.fetch(request)
                seal(courseBeneficiaries)
            } catch {
                print("CourseBeneficiariesPersistenceService :: failed fetch with error = \(error)")
                seal([])
            }
        }
    }
}
