import CoreData
import PromiseKit

protocol CourseListsPersistenceServiceProtocol: AnyObject {
    func fetch(id: CourseListModel.IdType) -> Guarantee<CourseListModel?>
    func fetch(ids: [CourseListModel.IdType]) -> Guarantee<[CourseListModel]>
}

final class CourseListsPersistenceService: BasePersistenceService<CourseListModel>,
                                           CourseListsPersistenceServiceProtocol {}
