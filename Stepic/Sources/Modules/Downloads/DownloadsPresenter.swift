import UIKit

protocol DownloadsPresenterProtocol {
    func presentSomeActionResult(response: Downloads.SomeAction.Response)
}

final class DownloadsPresenter: DownloadsPresenterProtocol {
    weak var viewController: DownloadsViewControllerProtocol?

    func presentSomeActionResult(response: Downloads.SomeAction.Response) { }
}