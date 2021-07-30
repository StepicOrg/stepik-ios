import CoreData

final class StoryPartReaction: NSManagedObject, ManagedObject {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedPosition), ascending: true)]
    }
    
    var storyReaction: StoryReaction? {
        if let reaction = self.reaction {
            return StoryReaction(rawValue: reaction)
        }
        return nil
    }

    override var description: String {
        "StoryPartReaction(storyID: \(self.storyID), position: \(self.position), reaction: \(String(describing: self.reaction))"
    }

    static func insert(
        into context: NSManagedObjectContext,
        storyID: Int,
        position: Int,
        reaction: StoryReaction
    ) -> StoryPartReaction {
        let object: StoryPartReaction = context.insertObject()

        object.storyID = storyID
        object.position = position
        object.reaction = reaction.rawValue

        return object
    }
}
