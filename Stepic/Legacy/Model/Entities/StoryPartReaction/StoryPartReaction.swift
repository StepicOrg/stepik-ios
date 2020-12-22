import CoreData
import Foundation

final class StoryPartReaction: NSManagedObject {
    var storyReaction: StoryReaction? {
        if let reaction = self.reaction {
            return StoryReaction(rawValue: reaction)
        }
        return nil
    }

    override var description: String {
        "StoryPartReaction(storyID: \(self.storyID), position: \(self.position), reaction: \(String(describing: self.reaction))"
    }

    convenience init(
        storyID: Int,
        position: Int,
        reaction: StoryReaction,
        managedObjectContext: NSManagedObjectContext
    ) {
        guard let entity = NSEntityDescription.entity(
            forEntityName: "StoryPartReaction", in: managedObjectContext
        ) else {
            fatalError("Wrong object type")
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        self.storyID = storyID
        self.position = position
        self.reaction = reaction.rawValue
    }
}
