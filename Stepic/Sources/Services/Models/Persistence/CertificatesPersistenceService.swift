import CoreData
import PromiseKit

protocol CertificatesPersistenceServiceProtocol: AnyObject {
    func fetch(id: Certificate.IdType) -> Guarantee<Certificate?>
    func fetch(ids: [Certificate.IdType]) -> Guarantee<[Certificate]>
    func fetch(userID: User.IdType) -> Guarantee<[Certificate]>
    func fetch(courseID: Course.IdType, userID: User.IdType) -> Guarantee<[Certificate]>

    func deleteAll() -> Promise<Void>
}

final class CertificatesPersistenceService: BasePersistenceService<Certificate>,
                                            CertificatesPersistenceServiceProtocol {
    func fetch(userID: User.IdType) -> Guarantee<[Certificate]> {
        Guarantee { seal in
            let request = Certificate.sortedFetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(Certificate.managedUserId),
                NSNumber(value: userID)
            )
            request.returnsObjectsAsFaults = false

            do {
                let certificates = try self.managedObjectContext.fetch(request)
                seal(certificates)
            } catch {
                print("CertificatesPersistenceService :: failed fetch certificates user = \(userID), error = \(error)")
                seal([])
            }
        }
    }

    func fetch(courseID: Course.IdType, userID: User.IdType) -> Guarantee<[Certificate]> {
        Guarantee { seal in
            let request = Certificate.sortedFetchRequest
            request.returnsObjectsAsFaults = false

            let coursePredicate = NSPredicate(
                format: "%K == %@",
                #keyPath(Certificate.managedCourseId),
                NSNumber(value: courseID)
            )
            let userPredicate = NSPredicate(
                format: "%K == %@",
                #keyPath(Certificate.managedUserId),
                NSNumber(value: userID)
            )
            request.predicate = NSCompoundPredicate(type: .and, subpredicates: [coursePredicate, userPredicate])

            do {
                let certificates = try self.managedObjectContext.fetch(request)
                seal(certificates)
            } catch {
                print("CertificatesPersistenceService :: failed fetch certificates course = \(courseID) user = \(userID) error = \(error)")
                seal([])
            }
        }
    }
}
