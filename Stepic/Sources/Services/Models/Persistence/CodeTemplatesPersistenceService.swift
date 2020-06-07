import CoreData
import Foundation
import PromiseKit

protocol CodeTemplatesPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class CodeTemplatesPersistenceService: CodeTemplatesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<CodeTemplate> = CodeTemplate.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let codeTemplates = try self.managedObjectContext.fetch(request)
                    for codeTemplate in codeTemplates {
                        self.managedObjectContext.delete(codeTemplate)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("CodeTemplatePersistenceService :: failed delete all code templates with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
