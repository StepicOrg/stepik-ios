import CoreData

extension Assignment {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedStepId: NSNumber?
    @NSManaged var managedUnitId: NSNumber?
    @NSManaged var managedProgressId: String?

    @NSManaged var managedUnit: Unit?
    @NSManaged var managedProgress: Progress?

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var stepId: Int {
        get {
            self.managedStepId?.intValue ?? -1
        }
        set {
            self.managedStepId = NSNumber(value: newValue)
        }
    }

    var unitId: Int {
        get {
            self.managedUnitId?.intValue ?? -1
        }
        set {
            self.managedUnitId = NSNumber(value: newValue)
        }
    }

    var progressId: String {
        get {
            self.managedProgressId ?? ""
        }
        set {
            self.managedProgressId = newValue
        }
    }

    var unit: Unit? {
        get {
            self.managedUnit
        }
        set {
            self.managedUnit = newValue
        }
    }

    var progress: Progress? {
        get {
            self.managedProgress
        }
        set {
            self.managedProgress = newValue
        }
    }
}
