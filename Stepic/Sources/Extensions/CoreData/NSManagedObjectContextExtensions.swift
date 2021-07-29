import CoreData

extension NSManagedObjectContext {
    func insertObject<Object: NSManagedObject>() -> Object where Object: ManagedObject {
        guard let object = NSEntityDescription.insertNewObject(
            forEntityName: Object.entityName,
            into: self
        ) as? Object else {
            fatalError("Wrong object type")
        }
        return object
    }

    func saveOrRollback() -> Bool {
        guard self.hasChanges else {
            return true
        }

        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }

    func performSaveOrRollback() {
        perform {
            _ = self.saveOrRollback()
        }
    }

    func performChanges(block: @escaping () -> Void) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
}

// MARK: - NSManagedObjectContext (BatchRequests) -

extension NSManagedObjectContext {
    func executeAndMergeChanges(using batchDeleteRequest: NSBatchDeleteRequest) throws {
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }

    func executeAndMergeChanges(using batchUpdateRequest: NSBatchUpdateRequest) throws {
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        let result = try execute(batchUpdateRequest) as? NSBatchUpdateResult
        let changes: [AnyHashable: Any] = [NSUpdatedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}
