import CoreData
import Foundation

final class CatalogBlockEntity: NSManagedObject {
    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "CatalogBlockEntity", in: CoreDataHelper.shared.context)!
    }

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
            (self.managedContent as? [CatalogBlockContentItem]) ?? []
        }
        set {
            self.managedContent = newValue as NSObject?
        }
    }

    convenience init() {
        self.init(entity: Self.oldEntity, insertInto: CoreDataHelper.shared.context)
    }
}

// MARK: - CatalogBlockEntity (PlainObject Support) -

extension CatalogBlockEntity {
    var plainObject: CatalogBlock {
        CatalogBlock(
            id: self.id,
            position: self.position,
            title: self.title,
            language: self.language,
            descriptionString: self.descriptionString,
            kindString: self.kind,
            appearanceString: self.appearance,
            isTitleVisible: self.isTitleVisible,
            content: self.content
        )
    }

    convenience init(catalogBlock: CatalogBlock, managedObjectContext: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(
            forEntityName: "CatalogBlockEntity", in: managedObjectContext
        ) else {
            fatalError("Wrong object type")
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        self.id = catalogBlock.id
        self.position = catalogBlock.position
        self.title = catalogBlock.title
        self.language = catalogBlock.language
        self.descriptionString = catalogBlock.descriptionString
        self.kind = catalogBlock.kindString
        self.appearance = catalogBlock.appearanceString
        self.isTitleVisible = catalogBlock.isTitleVisible
        self.content = catalogBlock.content
    }
}
