import Foundation

protocol CatalogBlocksOutputProtocol: CourseListOutputProtocol {
    func presentCourseList(type: CourseListType)
    func presentProfile(id: User.IdType)
    func hideCatalogBlocks()
}
