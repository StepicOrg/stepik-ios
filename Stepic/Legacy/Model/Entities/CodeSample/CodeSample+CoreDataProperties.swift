import CoreData

extension CodeSample {
    @NSManaged var managedInput: String?
    @NSManaged var managedOutput: String?

    @NSManaged var managedOptions: StepOptions?

    var input: String {
        get {
            self.managedInput ?? ""
        }
        set {
            self.managedInput = newValue
        }
    }

    var output: String {
        get {
            self.managedOutput ?? ""
        }
        set {
            self.managedOutput = newValue
        }
    }
}
