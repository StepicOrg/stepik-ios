import UIKit

protocol SimpleCourseListPresenterProtocol {
    func presentCourseList(response: SimpleCourseList.CourseListLoad.Response)
}

final class SimpleCourseListPresenter: SimpleCourseListPresenterProtocol {
    weak var viewController: SimpleCourseListViewControllerProtocol?

    func presentCourseList(response: SimpleCourseList.CourseListLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModels = data.map { self.makeViewModel($0) }
            self.viewController?.displayCourseList(viewModel: .init(state: .result(data: viewModels)))
        case .failure:
            break
        }
    }

    private func makeViewModel(
        _ contentItem: SimpleCourseListsCatalogBlockContentItem
    ) -> SimpleCourseListWidgetViewModel {
        SimpleCourseListWidgetViewModel(
            uniqueIdentifier: "\(contentItem.id)",
            title: contentItem.title,
            subtitle: FormatterHelper.catalogBlockCoursesCount(contentItem.coursesCount)
        )
    }
}
