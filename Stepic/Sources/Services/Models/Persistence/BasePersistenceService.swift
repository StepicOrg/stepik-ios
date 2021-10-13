import CoreData
import PromiseKit

class BasePersistenceService<Entity: NSManagedObject & ManagedObject> {
    private(set) var managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetchAll() -> Guarantee<[Entity]> {
        Guarantee { seal in
            self.managedObjectContext.perform {
                let request = Entity.sortedFetchRequest
                request.returnsObjectsAsFaults = false

                do {
                    let objects = try self.managedObjectContext.fetch(request)
                    seal(objects)
                } catch {
                    print("BasePersistenceService :: failed fetchAll with error = \(error)")
                    seal([])
                }
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            self.managedObjectContext.performAndWait {
                do {
                    let request = Entity.sortedFetchRequest
                    let objects = try self.managedObjectContext.fetch(request)

                    for object in objects {
                        self.managedObjectContext.delete(object)
                    }

                    self.managedObjectContext.saveOrRollback()

                    seal.fulfill(())
                } catch {
                    print("BasePersistenceService<\(Entity.entityName)> :: failed delete all with error = \(error)")
                    seal.reject(error)
                }
            }
        }
    }

    func deleteAllOptimized() -> Promise<Void> {
        Promise { seal in
            self.managedObjectContext.performAndWait {
                do {
                    try self.managedObjectContext.executeAndMergeChanges(using: Entity.batchDeleteRequest)
                    self.managedObjectContext.saveOrRollback()
                    seal.fulfill(())
                } catch {
                    print("BasePersistenceService<\(Entity.entityName)> :: failed delete all with error = \(error)")
                    seal.reject(error)
                }
            }
        }
    }
}

extension BasePersistenceService where Entity: Identifiable, Entity.ID: CoreDataRepresentable {
    func fetch(id: Entity.ID) -> Guarantee<Entity?> {
        Guarantee { seal in
            self.managedObjectContext.perform {
                let object = Entity.findOrFetch(in: self.managedObjectContext, byID: id)
                seal(object)
            }
        }
    }

    func fetch(ids: [Entity.ID]) -> Guarantee<[Entity]> {
        if ids.isEmpty {
            return .value([])
        }

        if ids.count == 1 {
            return self.fetch(id: ids[0]).map { objectOrNil -> [Entity] in
                if let object = objectOrNil {
                    return [object]
                }
                return []
            }
        }

        return Guarantee { seal in
            self.managedObjectContext.perform {
                let objects = Entity.fetch(in: self.managedObjectContext, byIDs: ids)
                seal(objects)
            }
        }
    }
}
