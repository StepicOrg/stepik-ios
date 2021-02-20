import UIKit

protocol SubmissionsFilterPresenterProtocol {
    func presentSubmissionsFilter(response: SubmissionsFilter.SubmissionsFilterLoad.Response)
}

final class SubmissionsFilterPresenter: SubmissionsFilterPresenterProtocol {
    weak var viewController: SubmissionsFilterViewControllerProtocol?

    func presentSubmissionsFilter(response: SubmissionsFilter.SubmissionsFilterLoad.Response) {
        self.viewController?.displaySubmissionsFilter(viewModel: .init(data: response.data))
    }
}
