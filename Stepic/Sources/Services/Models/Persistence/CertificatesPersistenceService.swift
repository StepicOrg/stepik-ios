import CoreData
import PromiseKit
import StepikModel

protocol CertificatesPersistenceServiceProtocol: AnyObject {
    func fetch(id: Certificate.IdType) -> Guarantee<Certificate?>
    func fetch(ids: [Certificate.IdType]) -> Guarantee<[Certificate]>
    func fetch(userID: User.IdType) -> Guarantee<[Certificate]>
    func fetch(courseID: Course.IdType, userID: User.IdType) -> Guarantee<[Certificate]>

    func save(certificates: [StepikModel.Certificate]) -> Guarantee<[Certificate]>

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
                print(
                    """
                    CertificatesPersistenceService :: failed fetch certificates course = \(courseID), \
                    user = \(userID), error = \(error)
                    """
                )
                seal([])
            }
        }
    }

    func save(certificates: [StepikModel.Certificate]) -> Guarantee<[Certificate]> {
        Guarantee { seal in
            firstly {
                self.fetch(ids: certificates.map(\.id))
            }.map { cachedCertificates in
                Dictionary(cachedCertificates.map({ ($0.id, $0) }), uniquingKeysWith: { first, _ in first })
            }.done { cachedCertificatesMap in
                self.managedObjectContext.performChanges {
                    var result = [Certificate]()

                    for certificate in certificates {
                        if let cachedCertificate = cachedCertificatesMap[certificate.id] {
                            cachedCertificate.update(certificate: certificate)
                            result.append(cachedCertificate)
                        } else {
                            let insertedCertificate = Certificate.insert(
                                into: self.managedObjectContext,
                                certificate: certificate
                            )
                            result.append(insertedCertificate)
                        }
                    }

                    seal(result)
                }
            }
        }
    }
}
