import CoreData
import Foundation
import PromiseKit

protocol SectionsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Section.IdType]) -> Promise<[Section]>
    func fetch(id: Section.IdType) -> Promise<Section?>

    func deleteAll() -> Promise<Void>
}

final class SectionsPersistenceService: SectionsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [Section.IdType]) -> Promise<[Section]> {
        Promise { seal in
            Section.fetchAsync(ids: ids).done { sections in
                let sections = Array(Set(sections)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(sections)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: Section.IdType) -> Promise<Section?> {
        Promise { seal in
            Section.fetchAsync(ids: [id]).done { sections in
                seal.fulfill(sections.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<Section> = Section.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let sections = try self.managedObjectContext.fetch(request)
                    for section in sections {
                        self.managedObjectContext.delete(section)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("SectionsPersistenceService :: failed delete all sections with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case deleteFailed
    }
}
