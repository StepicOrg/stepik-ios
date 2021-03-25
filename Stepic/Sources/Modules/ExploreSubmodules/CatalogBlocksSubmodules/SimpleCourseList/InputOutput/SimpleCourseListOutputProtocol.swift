import Foundation

protocol SimpleCourseListOutputProtocol: AnyObject {
    func presentSimpleCourseList(
        type: CatalogBlockCourseListType,
        presentationDescription: CourseList.PresentationDescription?
    )
}
