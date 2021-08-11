import CoreData

extension UserActivityEntity {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedPinsArray: NSObject?

    @NSManaged var managedProfile: Profile?

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var pins: [Int] {
        get {
            self.managedPinsArray as? [Int] ?? []
        }
        set {
            self.managedPinsArray = NSArray(array: newValue)
        }
    }

    var profile: Profile? {
        get {
            self.managedProfile
        }
        set {
            self.managedProfile = newValue
        }
    }
}
