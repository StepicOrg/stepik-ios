import CoreData
import Foundation
import PromiseKit

protocol UsersPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [User.IdType]) -> Guarantee<[User]>
    func fetch(id: User.IdType) -> Guarantee<User?>
}

final class UsersPersistenceService: UsersPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [User.IdType]) -> Guarantee<[User]> {
        firstly {
            self.fetchUsers(ids: ids)
        }.map { users in
            Array(Set(users)).reordered(order: ids, transform: { $0.id })
        }
    }

    func fetch(id: User.IdType) -> Guarantee<User?> {
        firstly {
            self.fetchUsers(ids: [id])
        }.then { users in
            .value(users.first)
        }
    }

    private func fetchUsers(ids: [User.IdType]) -> Guarantee<[User]> {
        Guarantee { seal in
            let idSubpredicates = ids.map { id in
                NSPredicate(format: "%K == %@", #keyPath(User.managedId), NSNumber(value: id))
            }
            let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idSubpredicates)

            let request: NSFetchRequest<User> = User.fetchRequest()
            request.predicate = compoundPredicate
            request.sortDescriptors = User.defaultSortDescriptors
            request.returnsObjectsAsFaults = false

            self.managedObjectContext.performAndWait {
                do {
                    let users = try self.managedObjectContext.fetch(request)
                    seal(users)
                } catch {
                    print("Error while fetching users = \(ids)")
                    seal([])
                }
            }
        }
    }
}
