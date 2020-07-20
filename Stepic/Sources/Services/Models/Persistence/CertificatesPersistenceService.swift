import CoreData
import Foundation
import PromiseKit

protocol CertificatesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Certificate.IdType], userID: User.IdType) -> Guarantee<[Certificate]>
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
