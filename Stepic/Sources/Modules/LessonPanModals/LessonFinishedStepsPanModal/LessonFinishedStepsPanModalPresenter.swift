import UIKit

protocol LessonFinishedStepsPanModalPresenterProtocol {
    func presentModal(response: LessonFinishedStepsPanModal.ModalLoad.Response)
}

final class LessonFinishedStepsPanModalPresenter: LessonFinishedStepsPanModalPresenterProtocol {
    weak var viewController: LessonFinishedStepsPanModalViewControllerProtocol?

    func presentModal(response: LessonFinishedStepsPanModal.ModalLoad.Response) {}
}
