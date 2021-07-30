import CoreData

extension Notification {
    // FIXME: Move to NotificationsPersistenceService

    @available(*, deprecated, message: "Legacy")
    static func fetch(_ ids: [Int]) -> [Notification] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notification")

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0 as NSNumber)
        }
        request.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)
        do {
            guard let results = try CoreDataHelper.shared.context.fetch(request) as? [Notification] else {
                return []
            }
            return results
        } catch {
            return []
        }
    }

    @available(*, deprecated, message: "Legacy")
    static func fetch(id: Int) -> Notification? {
        self.fetch([id]).first
    }

    @available(*, deprecated, message: "Legacy")
    static func fetch(type: NotificationType?, offset: Int = 0, limit: Int = 10) -> [Notification]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notification")
        let sort = NSSortDescriptor(key: "managedTime", ascending: false)
        request.fetchLimit = limit
        request.fetchOffset = offset
        request.sortDescriptors = [sort]

        if let type = type {
            request.predicate = NSPredicate(format: "managedType == %@", type.rawValue as NSString)
        } else {
            request.predicate = NSPredicate(value: true)
        }

        do {
            guard let results = try CoreDataHelper.shared.context.fetch(request) as? [Notification] else {
                return nil
            }
            return results
        } catch {
            return nil
        }
    }

    @available(*, deprecated, message: "Legacy")
    static func markAllAsRead() {
        let request = NSBatchUpdateRequest(entityName: "Notification")
        request.predicate = NSPredicate(value: true)
        request.propertiesToUpdate = ["managedStatus": "read"]

        do {
            _ = try CoreDataHelper.shared.context.execute(request)
        } catch {
            print("notification: couldn't update all notifications!")
        }
    }
}
