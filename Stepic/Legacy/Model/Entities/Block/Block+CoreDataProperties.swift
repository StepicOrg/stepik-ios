import CoreData

extension Block {
    @NSManaged var managedName: String?
    @NSManaged var managedText: String?

    @NSManaged var managedVideo: Video?
    @NSManaged var managedStep: Step?

    var name: String {
        get {
            self.managedName ?? "undefined"
        }
        set {
            self.managedName = newValue
        }
    }

    var text: String? {
        get {
            self.managedText
        }
        set {
            self.managedText = newValue
        }
    }

    var video: Video? {
        get {
            self.managedVideo
        }
        set {
            self.managedVideo = newValue
        }
    }
}
