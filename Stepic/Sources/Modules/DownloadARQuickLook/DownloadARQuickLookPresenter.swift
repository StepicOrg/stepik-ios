import UIKit

protocol DownloadARQuickLookPresenterProtocol {
    func presentSomeActionResult(response: DownloadARQuickLook.SomeAction.Response)
}

final class DownloadARQuickLookPresenter: DownloadARQuickLookPresenterProtocol {
    weak var viewController: DownloadARQuickLookViewControllerProtocol?

    func presentSomeActionResult(response: DownloadARQuickLook.SomeAction.Response) {}
}
