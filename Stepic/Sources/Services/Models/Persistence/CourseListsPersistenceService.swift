import CoreData
import Foundation
import PromiseKit

protocol CourseListsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [CourseListModel.IdType]) -> Guarantee<[CourseListModel]>
}

extension CourseListsPersistenceServiceProtocol {
    func fetch(id: CourseListModel.IdType) -> Guarantee<CourseListModel?> {
        Guarantee { seal in
            self.fetch(ids: [id]).done { courseLists in
                seal(courseLists.first)
            }
        }
    }
}

final class CourseListsPersistenceService: CourseListsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [CourseListModel.IdType]) -> Guarantee<[CourseListModel]> {
        Guarantee { seal in
            let request = NSFetchRequest<CourseListModel>(entityName: "CourseList")

            let idSubpredicates = ids.map { id in
                NSPredicate(format: "%K == %@", #keyPath(CourseListModel.managedId), NSNumber(value: id))
            }
            let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idSubpredicates)

            request.predicate = compoundPredicate
            request.sortDescriptors = [NSSortDescriptor(key: "managedPosition", ascending: true)]

            self.managedObjectContext.performAndWait {
                do {
                    let courseLists = try self.managedObjectContext.fetch(request)
                    seal(courseLists)
                } catch {
                    print("Error while fetching course lists = \(ids)")
                    seal([])
                }
            }
        }
    }
}
