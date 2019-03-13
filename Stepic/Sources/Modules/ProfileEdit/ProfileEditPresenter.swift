import UIKit

protocol ProfileEditPresenterProtocol {
    func presentSomeActionResult(response: ProfileEdit.SomeAction.Response)
}

final class ProfileEditPresenter: ProfileEditPresenterProtocol {
    weak var viewController: ProfileEditViewControllerProtocol?

    func presentSomeActionResult(response: ProfileEdit.SomeAction.Response) { }
}