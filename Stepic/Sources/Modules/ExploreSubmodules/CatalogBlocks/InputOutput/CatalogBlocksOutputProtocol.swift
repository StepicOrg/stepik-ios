import Foundation

protocol CatalogBlocksOutputProtocol: CourseListOutputProtocol {
    func presentCourseList(type: CatalogBlockCourseListType)
    func presentProfile(id: User.IdType)
    func hideCatalogBlocks()
}
