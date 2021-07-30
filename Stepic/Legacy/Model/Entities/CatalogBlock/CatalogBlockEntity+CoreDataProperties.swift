import CoreData
import Foundation

extension CatalogBlockEntity {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedPosition: NSNumber?
    @NSManaged var managedTitle: String?
    @NSManaged var managedDescription: String?
    @NSManaged var managedLanguage: String?
    @NSManaged var managedPlatform: NSNumber?
    @NSManaged var managedKind: String?
    @NSManaged var managedAppearance: String?
    @NSManaged var managedIsTitleVisible: NSNumber?
    @NSManaged var managedContent: NSObject?

    var id: Int {
        get {
            self.managedId?.intValue ?? 0
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var position: Int {
        get {
            self.managedPosition?.intValue ?? 0
        }
        set {
            self.managedPosition = NSNumber(value: newValue)
        }
    }

    var title: String {
        get {
            self.managedTitle ?? ""
        }
        set {
            self.managedTitle = newValue
        }
    }

    var descriptionString: String {
        get {
            self.managedDescription ?? ""
        }
        set {
            self.managedDescription = newValue
        }
    }

    var language: String {
        get {
            self.managedLanguage ?? ""
        }
        set {
            self.managedLanguage = newValue
        }
    }

    var platform: Int {
        get {
            self.managedPlatform?.intValue ?? PlatformType.ios.rawValue
        }
        set {
            self.managedPlatform = NSNumber(value: newValue)
        }
    }

    var kind: String {
        get {
            self.managedKind ?? ""
        }
        set {
            self.managedKind = newValue
        }
    }

    var appearance: String {
        get {
            self.managedAppearance ?? ""
        }
        set {
            self.managedAppearance = newValue
        }
    }

    var isTitleVisible: Bool {
        get {
            self.managedIsTitleVisible?.boolValue ?? true
        }
        set {
            self.managedIsTitleVisible = NSNumber(value: newValue)
        }
    }

    var content: [CatalogBlockContentItem] {
        get {
            self.managedContent as? [CatalogBlockContentItem] ?? []
        }
        set {
            self.managedContent = NSArray(array: newValue)
        }
    }
}
