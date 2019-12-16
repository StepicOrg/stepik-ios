import Foundation

protocol CourseListCollectionOutputProtocol: AnyObject {
    func presentCourseList(
        presentationDescription: CourseList.PresentationDescription,
        type: CollectionCourseListType
    )
}
