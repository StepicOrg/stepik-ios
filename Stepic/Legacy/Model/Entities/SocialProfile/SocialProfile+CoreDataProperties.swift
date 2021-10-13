import CoreData

extension SocialProfile {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedProvider: String?
    @NSManaged var managedName: String?
    @NSManaged var managedURL: String?

    @NSManaged var managedUser: User?

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var userID: Int {
        get {
            self.managedUserId?.intValue ?? -1
        }
        set {
            self.managedUserId = NSNumber(value: newValue)
        }
    }

    var providerString: String {
        get {
            self.managedProvider ?? ""
        }
        set {
            self.managedProvider = newValue
        }
    }

    var name: String {
        get {
            self.managedName ?? ""
        }
        set {
            self.managedName = newValue
        }
    }

    var urlString: String {
        get {
            self.managedURL ?? ""
        }
        set {
            self.managedURL = newValue
        }
    }

    var user: User? {
        get {
            self.managedUser
        }
        set {
            self.managedUser = newValue
        }
    }
}
