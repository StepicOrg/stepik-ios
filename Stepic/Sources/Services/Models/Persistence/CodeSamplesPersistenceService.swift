import CoreData
import Foundation
import PromiseKit

protocol CodeSamplesPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class CodeSamplesPersistenceService: CodeSamplesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<CodeSample> = CodeSample.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let codeSamples = try self.managedObjectContext.fetch(request)
                    for codeSample in codeSamples {
                        self.managedObjectContext.delete(codeSample)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("CodeSamplesPersistenceService :: failed delete all code samples with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
