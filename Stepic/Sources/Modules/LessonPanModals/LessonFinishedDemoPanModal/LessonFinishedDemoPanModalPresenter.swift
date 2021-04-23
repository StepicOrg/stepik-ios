import UIKit

protocol LessonFinishedDemoPanModalPresenterProtocol {
    func presentSomeActionResult(response: LessonFinishedDemoPanModal.SomeAction.Response)
}

final class LessonFinishedDemoPanModalPresenter: LessonFinishedDemoPanModalPresenterProtocol {
    weak var viewController: LessonFinishedDemoPanModalViewControllerProtocol?

    func presentSomeActionResult(response: LessonFinishedDemoPanModal.SomeAction.Response) {}
}
