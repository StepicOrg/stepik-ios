import CoreData

protocol ManagedObject: NSFetchRequestResult {
    static var entity: NSEntityDescription { get }
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    static var defaultPredicate: NSPredicate { get }

    var managedObjectContext: NSManagedObjectContext? { get }
}

extension ManagedObject {
    static var defaultSortDescriptors: [NSSortDescriptor] { [] }
    static var defaultPredicate: NSPredicate { NSPredicate(value: true) }

    static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: self.entityName)
        request.sortDescriptors = self.defaultSortDescriptors
        request.predicate = self.defaultPredicate
        return request
    }

    static func sortedFetchRequest(with predicate: NSPredicate) -> NSFetchRequest<Self> {
        let request = self.sortedFetchRequest
        guard let existingPredicate = request.predicate else { fatalError("must have predicate") }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, predicate])
        return request
    }

    static func predicate(format: String, _ args: CVarArg...) -> NSPredicate {
        let predicate = withVaList(args) { NSPredicate(format: format, arguments: $0) }
        return self.predicate(predicate)
    }

    static func predicate(_ predicate: NSPredicate) -> NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [self.defaultPredicate, predicate])
    }
}

extension ManagedObject where Self: NSManagedObject {
    static var entity: NSEntityDescription { entity() }

    // swiftlint:disable:next force_unwrapping
    static var entityName: String { self.entity.name! }

    /// Checks if the object is already registered in the context, and if not, it tries to load it using a fetch request.
    static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        if let inMemoryObject = self.materializedObject(in: context, matching: predicate) {
            return inMemoryObject
        } else {
            return try? self.fetch(in: context) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
            }.first
        }
    }

    /// Helper method that makes easier to execute fetch requests.
    /// Combines the configuration and the execution of a fetch request.
    static func fetch(
        in context: NSManagedObjectContext,
        configurationBlock: (NSFetchRequest<Self>) -> Void = { _ in }
    ) throws -> [Self] {
        let request = NSFetchRequest<Self>(entityName: self.entityName)
        configurationBlock(request)
        return try context.fetch(request)
    }

    /// Iterates over the context’s `registeredObjects` set, which contains all managed objects the context currently knows about.
    /// It does this until it finds one that isn’t a fault, is of the correct type, and matches a given predicate.
    static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self,
                  predicate.evaluate(with: result) else {
                continue
            }
            return result
        }
        return nil
    }
}
