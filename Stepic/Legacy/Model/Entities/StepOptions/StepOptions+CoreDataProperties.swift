import CoreData

extension StepOptions {
    @NSManaged var managedExecutionTimeLimit: NSNumber?
    @NSManaged var managedExecutionMemoryLimit: NSNumber?
    @NSManaged var managedIsRunUserCodeAllowed: NSNumber?

    @NSManaged var managedLimits: NSOrderedSet?
    @NSManaged var managedTemplates: NSOrderedSet?
    @NSManaged var managedSamples: NSOrderedSet?

    var executionTimeLimit: Double {
        get {
            self.managedExecutionTimeLimit?.doubleValue ?? 0.0
        }
        set {
            self.managedExecutionTimeLimit = newValue as NSNumber?
        }
    }

    var executionMemoryLimit: Double {
        get {
            self.managedExecutionMemoryLimit?.doubleValue ?? 0.0
        }
        set {
            self.managedExecutionMemoryLimit = newValue as NSNumber?
        }
    }

    var isRunUserCodeAllowed: Bool {
        get {
            self.managedIsRunUserCodeAllowed?.boolValue ?? false
        }
        set {
            self.managedIsRunUserCodeAllowed = newValue as NSNumber?
        }
    }

    var limits: [CodeLimit] {
        get {
            (managedLimits?.array as? [CodeLimit]) ?? []
        }
        set(value) {
            managedLimits = NSOrderedSet(array: value)
        }
    }

    var templates: [CodeTemplate] {
        get {
            (managedTemplates?.array as? [CodeTemplate]) ?? []
        }
        set(value) {
            managedTemplates = NSOrderedSet(array: value)
        }
    }

    var samples: [CodeSample] {
        get {
            (managedSamples?.array as? [CodeSample]) ?? []
        }
        set(value) {
            managedSamples = NSOrderedSet(array: value)
        }
    }
}
