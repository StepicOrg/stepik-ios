import CoreData

extension LastStep {
    @NSManaged var managedId: String?
    @NSManaged var managedStepId: NSNumber?
    @NSManaged var managedUnitId: NSNumber?

    @NSManaged var managedCourse: Course?

    var id: String {
        set(newId) {
            self.managedId = newId
        }
        get {
            if managedId == nil {
                print("Requested LastStep id when it is nil")
            }
            return managedId ?? "-1"
        }
    }

    var stepId: Int? {
        set(newId) {
            self.managedStepId = newId as NSNumber?
        }
        get {
            managedStepId?.intValue
        }
    }

    var unitId: Int? {
        set(newId) {
            self.managedUnitId = newId as NSNumber?
        }
        get {
            managedUnitId?.intValue
        }
    }
}
