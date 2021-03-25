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

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedPosition), ascending: true)]
    }

    static var fetchRequest: NSFetchRequest<CatalogBlockEntity> {
        NSFetchRequest<CatalogBlockEntity>(entityName: "CatalogBlockEntity")
    }
}
