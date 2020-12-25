import UIKit

protocol AuthorsCourseListPresenterProtocol {
    func presentCourseList(response: AuthorsCourseList.CourseListLoad.Response)
}

final class AuthorsCourseListPresenter: AuthorsCourseListPresenterProtocol {
    weak var viewController: AuthorsCourseListViewControllerProtocol?

    func presentCourseList(response: AuthorsCourseList.CourseListLoad.Response) {
        switch response.result {
        case .success(let result):
            let viewModels: [AuthorsCourseListWidgetViewModel]

            switch result {
            case .catalogBlockContentItems(let contentItems):
                viewModels = contentItems.map { self.makeViewModel(contentItem: $0) }
            case .users(let users):
                viewModels = users.map { self.makeViewModel(user: $0) }
            }

            self.viewController?.displayCourseList(viewModel: .init(state: .result(data: viewModels)))
        case .failure:
            break
        }
    }

    // MARK: Private API

    private func makeViewModel(contentItem: AuthorsCatalogBlockContentItem) -> AuthorsCourseListWidgetViewModel {
        self.makeViewModel(
            id: contentItem.id,
            fullName: contentItem.fullName,
            avatar: contentItem.avatar,
            createdCoursesCount: contentItem.createdCoursesCount,
            followersCount: contentItem.followersCount
        )
    }

    private func makeViewModel(user: User) -> AuthorsCourseListWidgetViewModel {
        self.makeViewModel(
            id: user.id,
            fullName: user.fullName,
            avatar: user.avatarURL,
            createdCoursesCount: user.createdCoursesCount,
            followersCount: user.followersCount
        )
    }

    private func makeViewModel(
        id: Int,
        fullName: String,
        avatar: String,
        createdCoursesCount: Int,
        followersCount: Int
    ) -> AuthorsCourseListWidgetViewModel {
        let formattedCreatedCoursesCountString = createdCoursesCount > 0
            ? FormatterHelper.coursesCount(createdCoursesCount)
            : ""
        let formattedFollowersCountString = followersCount > 0
            ? FormatterHelper.longFollowersCount(followersCount)
            : ""

        return AuthorsCourseListWidgetViewModel(
            uniqueIdentifier: "\(id)",
            title: fullName,
            avatarURLString: avatar,
            formattedCreatedCoursesCountString: formattedCreatedCoursesCountString,
            formattedFollowersCountString: formattedFollowersCountString
        )
    }
}
