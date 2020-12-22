import CoreData
import Foundation

extension StoryPartReaction {
    @NSManaged var managedStoryId: NSNumber?
    @NSManaged var managedPosition: NSNumber?
    @NSManaged var managedReaction: String?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "StoryPartReaction", in: CoreDataHelper.shared.context)!
    }

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedPosition), ascending: true)]
    }

    static var fetchRequest: NSFetchRequest<StoryPartReaction> {
        NSFetchRequest<StoryPartReaction>(entityName: "StoryPartReaction")
    }

    convenience init() {
        self.init(entity: Self.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var storyID: Int {
        get {
            self.managedStoryId?.intValue ?? 0
        }
        set {
            self.managedStoryId = NSNumber(value: newValue)
        }
    }

    var position: Int {
        get {
            self.managedPosition?.intValue ?? 0
        }
        set {
            self.managedPosition = NSNumber(value: newValue)
        }
    }

    var reaction: String? {
        get {
            self.managedReaction
        }
        set {
            self.managedReaction = newValue
        }
    }
}
