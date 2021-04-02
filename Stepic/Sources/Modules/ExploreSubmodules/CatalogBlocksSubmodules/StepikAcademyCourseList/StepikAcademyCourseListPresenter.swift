import UIKit

protocol StepikAcademyCourseListPresenterProtocol {
    func presentCourseList(response: StepikAcademyCourseList.CourseListLoad.Response)
}

final class StepikAcademyCourseListPresenter: StepikAcademyCourseListPresenterProtocol {
    weak var viewController: StepikAcademyCourseListViewControllerProtocol?

    func presentCourseList(response: StepikAcademyCourseList.CourseListLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModels = data.map(self.makeViewModel)
            self.viewController?.displayCourseList(viewModel: .init(state: .result(data: viewModels)))
        case .failure:
            break
        }
    }

    private func makeViewModel(
        contentItem: SpecializationsCatalogBlockContentItem
    ) -> StepikAcademyCourseListWidgetViewModel {
        StepikAcademyCourseListWidgetViewModel(
            uniqueIdentifier: "\(contentItem.id)",
            title: contentItem.title
        )
    }
}
