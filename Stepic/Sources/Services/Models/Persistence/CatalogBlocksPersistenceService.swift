import CoreData
import Foundation
import PromiseKit

protocol CatalogBlocksPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [CatalogBlock.IdType]) -> Guarantee<[CatalogBlockEntity]>
    func fetch(language: ContentLanguage) -> Guarantee<[CatalogBlockEntity]>

    func save(catalogBlocks: [CatalogBlock]) -> Guarantee<Void>

    func deleteAll() -> Promise<Void>
}

extension CatalogBlocksPersistenceServiceProtocol {
    func fetch(id: CatalogBlock.IdType) -> Guarantee<CatalogBlockEntity?> {
        self.fetch(ids: [id]).then { catalogBlocks in
            .value(catalogBlocks.first)
        }
    }
}

final class CatalogBlocksPersistenceService: CatalogBlocksPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(
        managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context
    ) {
        self.managedObjectContext = managedObjectContext
    }

    // MARK: Public API

    func fetch(ids: [CatalogBlock.IdType]) -> Guarantee<[CatalogBlockEntity]> {
        Guarantee { seal in
            let request = CatalogBlockEntity.fetchRequest

            let idSubpredicates = ids.map { id in
                NSPredicate(format: "%K == %@", #keyPath(CatalogBlockEntity.managedId), NSNumber(value: id))
            }
            let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idSubpredicates)

            request.predicate = compoundPredicate
            request.sortDescriptors = CatalogBlockEntity.defaultSortDescriptors

            self.managedObjectContext.performAndWait {
                do {
                    let catalogBlocks = try self.managedObjectContext.fetch(request)
                    seal(catalogBlocks)
                } catch {
                    print("Error while fetching catalog blocks = \(ids)")
                    seal([])
                }
            }
        }
    }

    func fetch(language: ContentLanguage) -> Guarantee<[CatalogBlockEntity]> {
        Guarantee { seal in
            let request = CatalogBlockEntity.fetchRequest
            request.sortDescriptors = CatalogBlockEntity.defaultSortDescriptors
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CatalogBlockEntity.managedLanguage),
                "\(language.languageString)"
            )
            request.sortDescriptors = CatalogBlockEntity.defaultSortDescriptors
            request.returnsObjectsAsFaults = false

            self.managedObjectContext.performAndWait {
                do {
                    let catalogBlocks = try self.managedObjectContext.fetch(request)
                    seal(catalogBlocks)
                } catch {
                    print("Error while fetching catalog blocks, error = \(error)")
                    seal([])
                }
            }
        }
    }

    func save(catalogBlocks: [CatalogBlock]) -> Guarantee<Void> {
        Guarantee { seal in
            let sortedCatalogBlocks = catalogBlocks.sorted { $0.position < $1.position }
            var catalogBlocksIterator = sortedCatalogBlocks.makeIterator()

            let insertGuaranteesIterator = AnyIterator<Guarantee<Void>> {
                guard let nextCatalogBlock = catalogBlocksIterator.next() else {
                    return nil
                }

                return self.insertOrReplace(catalogBlock: nextCatalogBlock)
            }

            when(fulfilled: insertGuaranteesIterator, concurrently: 1).done { _ in
                seal(())
            }.catch { _ in
                seal(())
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request = CatalogBlockEntity.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let catalogBlocks = try self.managedObjectContext.fetch(request)
                    for catalogBlock in catalogBlocks {
                        self.managedObjectContext.delete(catalogBlock)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("CatalogBlocksPersistenceService :: failed delete all catalogBlocks with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    // MARK: Private API

    private func insertOrReplace(catalogBlock: CatalogBlock) -> Guarantee<Void> {
        Guarantee { seal in
            DispatchQueue.main.promise { () -> Guarantee<[CatalogBlockEntity]> in
                self.fetch(id: catalogBlock.id)
            }.done { cachedCatalogBlockEntities in
                self.managedObjectContext.performAndWait {
                    for copy in cachedCatalogBlockEntities {
                        self.managedObjectContext.delete(copy)
                    }

                    if self.managedObjectContext.hasChanges {
                        try? self.managedObjectContext.save()
                    }

                    _ = CatalogBlockEntity(
                        catalogBlock: catalogBlock,
                        managedObjectContext: self.managedObjectContext
                    )

                    if self.managedObjectContext.hasChanges {
                        try? self.managedObjectContext.save()
                    }

                    seal(())
                }
            }.catch { _ in
                seal(())
            }
        }
    }

    private func fetch(id: CatalogBlock.IdType) -> Guarantee<[CatalogBlockEntity]> {
        Guarantee { seal in
            let request = CatalogBlockEntity.fetchRequest
            request.sortDescriptors = CatalogBlockEntity.defaultSortDescriptors
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CatalogBlockEntity.managedId),
                NSNumber(value: id)
            )
            request.sortDescriptors = CatalogBlockEntity.defaultSortDescriptors
            request.returnsObjectsAsFaults = false

            self.managedObjectContext.performAndWait {
                do {
                    let catalogBlocks = try self.managedObjectContext.fetch(request)
                    seal(catalogBlocks)
                } catch {
                    print("Error while fetching catalog block by id = \(id), error = \(error)")
                    seal([])
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
