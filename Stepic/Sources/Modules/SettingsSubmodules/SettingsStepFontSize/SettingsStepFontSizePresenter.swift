import UIKit

protocol SettingsStepFontSizePresenterProtocol {
    func presentSomeActionResult(response: SettingsStepFontSize.SomeAction.Response)
}

final class SettingsStepFontSizePresenter: SettingsStepFontSizePresenterProtocol {
    weak var viewController: SettingsStepFontSizeViewControllerProtocol?

    func presentSomeActionResult(response: SettingsStepFontSize.SomeAction.Response) { }
}