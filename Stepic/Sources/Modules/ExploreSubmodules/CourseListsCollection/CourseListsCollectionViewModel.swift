import Foundation

struct CourseListsCollectionViewModel {
    let title: String
    let description: String
    let summary: String?
    let courseList: CollectionCourseListType
    let color: GradientCoursesPlaceholderView.Color
    let collectionID: CourseListModel.IdType
}
