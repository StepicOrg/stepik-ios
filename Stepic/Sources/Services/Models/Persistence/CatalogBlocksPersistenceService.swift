import CoreData
import PromiseKit

protocol CatalogBlocksPersistenceServiceProtocol: AnyObject {
    func fetch(id: CatalogBlock.IdType) -> Guarantee<CatalogBlockEntity?>
    func fetch(ids: [CatalogBlock.IdType]) -> Guarantee<[CatalogBlockEntity]>
    func fetch(language: ContentLanguage) -> Guarantee<[CatalogBlockEntity]>

    func save(catalogBlocks: [CatalogBlock]) -> Guarantee<Void>
    func save(catalogBlocks: [CatalogBlock], forLanguage language: ContentLanguage) -> Guarantee<Void>

    func deleteAll() -> Promise<Void>
}

final class CatalogBlocksPersistenceService: BasePersistenceService<CatalogBlockEntity>,
                                             CatalogBlocksPersistenceServiceProtocol {
    func fetch(language: ContentLanguage) -> Guarantee<[CatalogBlockEntity]> {
        Guarantee { seal in
            do {
                let catalogBlocks = try CatalogBlockEntity.fetch(in: self.managedObjectContext) { request in
                    request.predicate = NSPredicate(
                        format: "%K == %@",
                        #keyPath(CatalogBlockEntity.managedLanguage),
                        "\(language.languageString)"
                    )
                    request.returnsObjectsAsFaults = false
                }
                seal(catalogBlocks)
            } catch {
                print("Error while fetching catalog blocks, error = \(error)")
                seal([])
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

                return self.insertOrUpdate(catalogBlock: nextCatalogBlock)
            }

            when(fulfilled: insertGuaranteesIterator, concurrently: 1).done { _ in
                seal(())
            }.catch { _ in
                seal(())
            }
        }
    }

    func save(catalogBlocks: [CatalogBlock], forLanguage language: ContentLanguage) -> Guarantee<Void> {
        Guarantee { seal in
            self.fetch(language: language).then { cachedCatalogBlocks -> Guarantee<Void> in
                let newIDs = Set(catalogBlocks.map(\.id))
                let cachedIDsToDelete = Set(cachedCatalogBlocks.map(\.id)).subtracting(newIDs)

                self.managedObjectContext.performAndWait {
                    for catalogBlock in cachedCatalogBlocks where cachedIDsToDelete.contains(catalogBlock.id) {
                        self.managedObjectContext.delete(catalogBlock)
                    }

                    self.managedObjectContext.saveOrRollback()
                }

                return self.save(catalogBlocks: catalogBlocks)
            }.done {
                seal(())
            }
        }
    }

    // MARK: Private API

    private func insertOrUpdate(catalogBlock: CatalogBlock) -> Guarantee<Void> {
        Guarantee { seal in
            DispatchQueue.main.promise { () -> Guarantee<CatalogBlockEntity?> in
                self.fetch(id: catalogBlock.id)
            }.done { cachedCatalogBlockOrNil in
                if let cachedCatalogBlock = cachedCatalogBlockOrNil {
                    cachedCatalogBlock.update(catalogBlock: catalogBlock)
                } else {
                    _ = CatalogBlockEntity.insert(into: self.managedObjectContext, catalogBlock: catalogBlock)
                }

                self.managedObjectContext.saveOrRollback()

                seal(())
            }.catch { _ in
                seal(())
            }
        }
    }
}
