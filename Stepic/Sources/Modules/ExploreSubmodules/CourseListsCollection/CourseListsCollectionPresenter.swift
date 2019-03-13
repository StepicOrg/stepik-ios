import Foundation

protocol CourseListsCollectionPresenterProtocol: class {
    func presentCourses(response: CourseListsCollection.CourseListsLoad.Response)
}

final class CourseListsCollectionPresenter: CourseListsCollectionPresenterProtocol {
    weak var viewController: CourseListsCollectionViewControllerProtocol?

    func presentCourses(response: CourseListsCollection.CourseListsLoad.Response) {
        switch response.result {
        case .success(let result):
            let courses = result.map { courseList in
                CourseListsCollectionViewModel(
                    title: courseList.title,
                    description: FormatterHelper.coursesCount(courseList.coursesArray.count),
                    summary: courseList.listDescription,
                    courseList: CollectionCourseListType(ids: courseList.coursesArray),
                    color: self.getColorForCourseList(courseList)
                )
            }
            let viewModel = CourseListsCollection.CourseListsLoad.ViewModel(state: .result(data: courses))
            self.viewController?.displayCourseLists(viewModel: viewModel)
        default:
            break
        }
    }

    private func getColorForCourseList(
        _ courseList: CourseListModel
    ) -> GradientCoursesPlaceholderView.Color {
        let number = courseList.title.hashValue % 2
        switch number {
        case 0:
            return .pink
        default:
            return .blue
        }
    }
}
