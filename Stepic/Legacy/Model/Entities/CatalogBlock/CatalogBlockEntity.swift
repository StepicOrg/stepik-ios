import CoreData

final class CatalogBlockEntity: NSManagedObject, ManagedObject, Identifiable {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedPosition), ascending: true)]
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
            platform: self.platform,
            descriptionString: self.descriptionString,
            kindString: self.kind,
            appearanceString: self.appearance,
            isTitleVisible: self.isTitleVisible,
            content: self.content
        )
    }

    static func insert(into context: NSManagedObjectContext, catalogBlock: CatalogBlock) -> CatalogBlockEntity {
        let catalogBlockEntity: CatalogBlockEntity = context.insertObject()
        catalogBlockEntity.update(catalogBlock: catalogBlock)
        return catalogBlockEntity
    }

    func update(catalogBlock: CatalogBlock) {
        self.id = catalogBlock.id
        self.position = catalogBlock.position
        self.title = catalogBlock.title
        self.language = catalogBlock.language
        self.platform = catalogBlock.platform
        self.descriptionString = catalogBlock.descriptionString
        self.kind = catalogBlock.kindString
        self.appearance = catalogBlock.appearanceString
        self.isTitleVisible = catalogBlock.isTitleVisible
        self.content = catalogBlock.content
    }
}
