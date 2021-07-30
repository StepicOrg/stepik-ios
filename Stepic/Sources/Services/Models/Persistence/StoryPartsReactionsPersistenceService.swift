import CoreData
import PromiseKit

protocol StoryPartsReactionsPersistenceServiceProtocol: AnyObject {
    func fetch(storyID: Int) -> Guarantee<[StoryPartReaction]>
    func save(reaction: StoryReaction, for storyPart: StoryPart) -> Guarantee<StoryPartReaction>
    func deleteAll() -> Promise<Void>
}

final class StoryPartsReactionsPersistenceService: BasePersistenceService<StoryPartReaction>,
                                                   StoryPartsReactionsPersistenceServiceProtocol {
    func fetch(storyID: Int) -> Guarantee<[StoryPartReaction]> {
        Guarantee { seal in
            let request = StoryPartReaction.sortedFetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(StoryPartReaction.managedStoryId),
                NSNumber(value: storyID)
            )
            request.returnsObjectsAsFaults = false

            do {
                let reactions = try self.managedObjectContext.fetch(request)
                seal(reactions)
            } catch {
                print("StoryPartsReactionsPersistenceService :: failed fetch with error = \(error)")
                seal([])
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

                    let storyPartReaction = StoryPartReaction.insert(
                        into: self.managedObjectContext,
                        storyID: storyPart.storyID,
                        position: storyPart.position,
                        reaction: reaction
                    )

                    self.managedObjectContext.saveOrRollback()

                    seal(storyPartReaction)
                }
            }
        }
    }
}
