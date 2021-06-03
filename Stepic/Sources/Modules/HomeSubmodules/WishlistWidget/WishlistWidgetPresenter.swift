import UIKit

protocol WishlistWidgetPresenterProtocol {
    func presentWishlist(response: WishlistWidget.WishlistLoad.Response)
    func presentFullscreenCourseList(response: WishlistWidget.FullscreenCourseListModulePresentation.Response)
}

final class WishlistWidgetPresenter: WishlistWidgetPresenterProtocol {
    weak var viewController: WishlistWidgetViewControllerProtocol?

    func presentWishlist(response: WishlistWidget.WishlistLoad.Response) {
        let viewModel: WishlistWidgetViewModel

        switch response.result {
        case .success(let data):
            viewModel = .init(
                formattedSubtitle: data.isEmpty
                    ? NSLocalizedString("WishlistWidgetEmptyMessage", comment: "")
                    : FormatterHelper.coursesCount(data.coursesIDs.count)
            )
        case .failure:
            viewModel = .init(formattedSubtitle: nil)
        }

        self.viewController?.displayWishlist(viewModel: .init(state: .result(data: viewModel)))
    }

    func presentFullscreenCourseList(response: WishlistWidget.FullscreenCourseListModulePresentation.Response) {
        self.viewController?.displayFullscreenCourseList(viewModel: .init(coursesIDs: response.coursesIDs))
    }
}
