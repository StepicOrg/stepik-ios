import Foundation

protocol CourseListCollectionOutputProtocol: class {
    func presentCourseList(
        presentationDescription: CourseList.PresentationDescription,
        type: CollectionCourseListType
    )
}
