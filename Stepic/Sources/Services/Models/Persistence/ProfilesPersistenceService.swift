import CoreData
import Foundation
import PromiseKit

protocol ProfilesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Profile.IdType]) -> Guarantee<[Profile]>
    func fetch(id: Profile.IdType) -> Guarantee<Profile?>
}

final class ProfilesPersistenceService: ProfilesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [Profile.IdType]) -> Guarantee<[Profile]> {
        firstly {
            self.fetchProfiles(ids: ids)
        }.map { profiles in
            Array(Set(profiles)).reordered(order: ids, transform: { $0.id })
        }
    }

    func fetch(id: Profile.IdType) -> Guarantee<Profile?> {
        firstly {
            self.fetchProfiles(ids: [id])
        }.then { profiles in
            .value(profiles.first)
        }
    }

    private func fetchProfiles(ids: [Profile.IdType]) -> Guarantee<[Profile]> {
        Guarantee { seal in
            let idSubpredicates = ids.map { id in
                NSPredicate(format: "%K == %@", #keyPath(Profile.managedId), NSNumber(value: id))
            }
            let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idSubpredicates)

            let request: NSFetchRequest<Profile> = Profile.fetchRequest()
            request.predicate = compoundPredicate
            request.sortDescriptors = Profile.defaultSortDescriptors
            request.returnsObjectsAsFaults = false

            self.managedObjectContext.performAndWait {
                do {
                    let profiles = try self.managedObjectContext.fetch(request)
                    seal(profiles)
                } catch {
                    print("Error while fetching Profiles = \(ids)")
                    seal([])
                }
            }
        }
    }
}
