import Foundation

protocol CatalogBlocksOutputProtocol: CourseListOutputProtocol {
    func presentCourseList(type: CatalogBlockCourseListType)
}
