import CoreData

extension StoryPartReaction {
    @NSManaged var managedStoryId: NSNumber?
    @NSManaged var managedPosition: NSNumber?
    @NSManaged var managedReaction: String?

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
