import UIKit

protocol LessonFinishedStepsPanModalPresenterProtocol {
    func presentSomeActionResult(response: LessonFinishedStepsPanModal.SomeAction.Response)
}

final class LessonFinishedStepsPanModalPresenter: LessonFinishedStepsPanModalPresenterProtocol {
    weak var viewController: LessonFinishedStepsPanModalViewControllerProtocol?

    func presentSomeActionResult(response: LessonFinishedStepsPanModal.SomeAction.Response) {}
}
