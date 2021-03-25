import Foundation

protocol CatalogBlocksOutputProtocol: CourseListOutputProtocol {
    func presentCourseList(type: CourseListType, presentationDescription: CourseList.PresentationDescription?)
    func presentProfile(id: User.IdType)
    func hideCatalogBlocks()
}
