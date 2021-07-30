import CoreData

extension DiscussionThread {
    @NSManaged var managedId: String?
    @NSManaged var managedThread: String?
    @NSManaged var managedDiscussionsCount: NSNumber?
    @NSManaged var managedDiscussionProxy: String?

    @NSManaged var managedStep: Step?

    var id: String {
        get {
            self.managedId ?? ""
        }
        set {
            self.managedId = newValue
        }
    }

    var thread: String {
        get {
            self.managedThread ?? ""
        }
        set {
            self.managedThread = newValue
        }
    }

    var discussionsCount: Int {
        get {
            self.managedDiscussionsCount?.intValue ?? 0
        }
        set {
            self.managedDiscussionsCount = newValue as NSNumber?
        }
    }

    var discussionProxy: String {
        get {
            self.managedDiscussionProxy ?? ""
        }
        set {
            self.managedDiscussionProxy = newValue
        }
    }

    var step: Step? {
        get {
            self.managedStep
        }
        set {
            self.managedStep = newValue
        }
    }
}
