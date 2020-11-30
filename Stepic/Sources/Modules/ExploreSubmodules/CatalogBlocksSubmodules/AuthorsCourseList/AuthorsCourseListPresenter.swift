import UIKit

protocol AuthorsCourseListPresenterProtocol {
    func presentCourseList(response: AuthorsCourseList.CourseListLoad.Response)
}

final class AuthorsCourseListPresenter: AuthorsCourseListPresenterProtocol {
    weak var viewController: AuthorsCourseListViewControllerProtocol?

    func presentCourseList(response: AuthorsCourseList.CourseListLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModels = data.map { self.makeViewModel($0) }
            self.viewController?.displayCourseList(viewModel: .init(state: .result(data: viewModels)))
        case .failure:
            break
        }
    }

    private func makeViewModel(
        _ contentItem: AuthorsCatalogBlockContentItem
    ) -> AuthorsCourseListWidgetViewModel {
        let formattedCreatedCoursesCountString = contentItem.createdCoursesCount > 0
            ? FormatterHelper.coursesCount(contentItem.createdCoursesCount)
            : ""
        let formattedFollowersCountString = contentItem.followersCount > 0
            ? FormatterHelper.longFollowersCount(contentItem.followersCount)
            : ""

        return AuthorsCourseListWidgetViewModel(
            uniqueIdentifier: "\(contentItem.id)",
            title: contentItem.fullName,
            avatarURLString: contentItem.avatar,
            formattedCreatedCoursesCountString: formattedCreatedCoursesCountString,
            formattedFollowersCountString: formattedFollowersCountString
        )
    }
}
