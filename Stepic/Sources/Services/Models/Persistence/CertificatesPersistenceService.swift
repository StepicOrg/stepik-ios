import CoreData
import Foundation
import PromiseKit

protocol CertificatesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Certificate.IdType], userID: User.IdType) -> Guarantee<[Certificate]>
    func fetch(userID: User.IdType) -> Guarantee<[Certificate]>
    func fetch(courseID: Course.IdType, userID: User.IdType) -> Guarantee<[Certificate]>
    func deleteAll() -> Promise<Void>
}

final class CertificatesPersistenceService: CertificatesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [Certificate.IdType], userID: User.IdType) -> Guarantee<[Certificate]> {
        Guarantee { seal in
            self.managedObjectContext.performAndWait {
                let certificates = Certificate.fetch(ids, user: userID)
                seal(certificates)
            }
        }
    }

    func fetch(userID: User.IdType) -> Guarantee<[Certificate]> {
        Guarantee { seal in
            let request: NSFetchRequest<Certificate> = Certificate.fetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(Certificate.managedUserId),
                NSNumber(value: userID)
            )
            request.sortDescriptors = Certificate.defaultSortDescriptors
            request.returnsObjectsAsFaults = false

            self.managedObjectContext.performAndWait {
                do {
                    let certificates = try self.managedObjectContext.fetch(request)
                    seal(certificates)
                } catch {
                    print("Error while fetching certificates for user = \(userID), error = \(error)")
                    seal([])
                }
            }
        }
    }

    func fetch(courseID: Course.IdType, userID: User.IdType) -> Guarantee<[Certificate]> {
        Guarantee { seal in
            let request: NSFetchRequest<Certificate> = Certificate.fetchRequest
            request.sortDescriptors = Certificate.defaultSortDescriptors
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

            self.managedObjectContext.performAndWait {
                do {
                    let certificates = try self.managedObjectContext.fetch(request)
                    seal(certificates)
                } catch {
                    print("Error fetching certificates for course = \(courseID) user = \(userID), error = \(error)")
                    seal([])
                }
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<Certificate> = Certificate.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let certificates = try self.managedObjectContext.fetch(request)
                    for certificate in certificates {
                        self.managedObjectContext.delete(certificate)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("CertificatesPersistenceService :: failed delete all certificates with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
