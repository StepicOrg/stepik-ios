import CoreData
import Foundation

extension SocialProfile {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedProvider: String?
    @NSManaged var managedName: String?
    @NSManaged var managedURL: String?

    @NSManaged var managedUser: User?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "SocialProfile", in: CoreDataHelper.shared.context)!
    }

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

    static var fetchRequest: NSFetchRequest<SocialProfile> {
        NSFetchRequest<SocialProfile>(entityName: "SocialProfile")
    }

    convenience init() {
        self.init(entity: Self.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

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
