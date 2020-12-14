import UIKit

protocol SimpleCourseListPresenterProtocol {
    func presentCourseList(response: SimpleCourseList.CourseListLoad.Response)
}

final class SimpleCourseListPresenter: SimpleCourseListPresenterProtocol {
    weak var viewController: SimpleCourseListViewControllerProtocol?

    func presentCourseList(response: SimpleCourseList.CourseListLoad.Response) {
        switch response.result {
        case .success(let result):
            let viewModels: [SimpleCourseListWidgetViewModel]

            switch result {
            case .catalogBlockContentItems(let contentItems):
                viewModels = contentItems.map { self.makeViewModel(contentItem: $0) }
            case .courseLists(let courseLists):
                viewModels = courseLists.map { self.makeViewModel(courseList: $0) }
            }

            self.viewController?.displayCourseList(viewModel: .init(state: .result(data: viewModels)))
        case .failure:
            break
        }
    }

    private func makeViewModel(
        contentItem: SimpleCourseListsCatalogBlockContentItem
    ) -> SimpleCourseListWidgetViewModel {
        self.makeViewModel(id: contentItem.id, title: contentItem.title, coursesCount: contentItem.coursesCount)
    }

    private func makeViewModel(courseList: CourseListModel) -> SimpleCourseListWidgetViewModel {
        self.makeViewModel(id: courseList.id, title: courseList.title, coursesCount: courseList.coursesArray.count)
    }

    private func makeViewModel(id: Int, title: String, coursesCount: Int) -> SimpleCourseListWidgetViewModel {
        SimpleCourseListWidgetViewModel(
            uniqueIdentifier: "\(id)",
            title: title,
            subtitle: FormatterHelper.catalogBlockCoursesCount(coursesCount)
        )
    }
}
