import UIKit

protocol NewProfileActivityPresenterProtocol {
    func presentUserActivity(response: NewProfileActivity.ActivityLoad.Response)
}

final class NewProfileActivityPresenter: NewProfileActivityPresenterProtocol {
    weak var viewController: NewProfileActivityViewControllerProtocol?

    func presentUserActivity(response: NewProfileActivity.ActivityLoad.Response) {}
}
