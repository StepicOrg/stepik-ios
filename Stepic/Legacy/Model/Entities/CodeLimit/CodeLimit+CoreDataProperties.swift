import CoreData

extension CodeLimit {
    @NSManaged var managedLanguage: String?
    @NSManaged var managedMemory: NSNumber?
    @NSManaged var managedTime: NSNumber?

    @NSManaged var managedOptions: StepOptions?

    var languageString: String {
        get {
            self.managedLanguage ?? ""
        }
        set {
            self.managedLanguage = newValue
        }
    }

    var memory: Double {
        get {
            self.managedMemory?.doubleValue ?? 0.0
        }
        set {
            self.managedMemory = NSNumber(value: newValue)
        }
    }

    var time: Double {
        get {
            self.managedTime?.doubleValue ?? 0.0
        }
        set {
            self.managedTime = NSNumber(value: newValue)
        }
    }
}
