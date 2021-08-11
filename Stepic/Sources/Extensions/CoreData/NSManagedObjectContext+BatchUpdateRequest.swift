import CoreData

extension NSManagedObjectContext {
    func executeAndMergeChanges(using batchUpdateRequest: NSBatchUpdateRequest) throws {
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        let result = try execute(batchUpdateRequest) as? NSBatchUpdateResult
        let changes: [AnyHashable: Any] = [NSUpdatedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}
