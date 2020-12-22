import CoreData
import Foundation
import PromiseKit

protocol StoryPartsReactionsPersistenceServiceProtocol: AnyObject {
    func fetch(storyID: Int) -> Guarantee<[StoryPartReaction]>
    func save(reaction: StoryReaction, for storyPart: StoryPart) -> Guarantee<StoryPartReaction>
    func deleteAll() -> Promise<Void>
}

final class StoryPartsReactionsPersistenceService: StoryPartsReactionsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(storyID: Int) -> Guarantee<[StoryPartReaction]> {
        Guarantee { seal in
            let request: NSFetchRequest<StoryPartReaction> = StoryPartReaction.fetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(StoryPartReaction.managedStoryId),
                NSNumber(value: storyID)
            )
            request.sortDescriptors = StoryPartReaction.defaultSortDescriptors
            request.returnsObjectsAsFaults = false

            self.managedObjectContext.performAndWait {
                do {
                    let reactions = try self.managedObjectContext.fetch(request)
                    seal(reactions)
                } catch {
                    print("StoryPartsReactionsPersistenceService :: failed fetch with error = \(error)")
                    seal([])
                }
            }
        }
    }

    func save(reaction: StoryReaction, for storyPart: StoryPart) -> Guarantee<StoryPartReaction> {
        Guarantee { seal in
            self.fetch(storyID: storyPart.storyID).then { reactions -> Guarantee<[StoryPartReaction]> in
                let filteredReactions = reactions.filter { $0.position == storyPart.position }
                return .value(filteredReactions)
            }.done { reactions in
                self.managedObjectContext.performAndWait {
                    for reaction in reactions {
                        self.managedObjectContext.delete(reaction)
                    }

                    if self.managedObjectContext.hasChanges {
                        try? self.managedObjectContext.save()
                    }

                    let storyPartReaction = StoryPartReaction(
                        storyID: storyPart.storyID,
                        position: storyPart.position,
                        reaction: reaction,
                        managedObjectContext: self.managedObjectContext
                    )

                    try? self.managedObjectContext.save()

                    seal(storyPartReaction)
                }
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<StoryPartReaction> = StoryPartReaction.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let reactions = try self.managedObjectContext.fetch(request)
                    for reaction in reactions {
                        self.managedObjectContext.delete(reaction)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("StoryPartsReactionsPersistenceService :: failed delete all with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
