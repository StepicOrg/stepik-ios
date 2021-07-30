import CoreData

extension CodeTemplate {
    @NSManaged var managedLanguage: String?
    @NSManaged var managedTemplateString: String?
    @NSManaged var managedIsUserGenerated: NSNumber?

    @NSManaged var managedOptions: StepOptions?

    var languageString: String {
        get {
            self.managedLanguage ?? ""
        }
        set {
            self.managedLanguage = newValue
        }
    }

    var templateString: String {
        get {
            self.managedTemplateString ?? ""
        }
        set {
            self.managedTemplateString = newValue
        }
    }

    var isUserGenerated: Bool {
        get {
            self.managedIsUserGenerated?.boolValue ?? true
        }
        set {
            self.managedIsUserGenerated = NSNumber(value: newValue)
        }
    }
}
