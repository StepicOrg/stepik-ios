import UIKit

protocol LessonFinishedDemoPanModalPresenterProtocol {
    func presentModal(response: LessonFinishedDemoPanModal.ModalLoad.Response)
}

final class LessonFinishedDemoPanModalPresenter: LessonFinishedDemoPanModalPresenterProtocol {
    weak var viewController: LessonFinishedDemoPanModalViewControllerProtocol?

    func presentModal(response: LessonFinishedDemoPanModal.ModalLoad.Response) {
        let title = String(
            format: NSLocalizedString("LessonFinishedDemoPanModalTitle", comment: ""),
            arguments: [response.section.title]
        )

        let actionButtonTitle = String(
            format: NSLocalizedString("WidgetButtonBuy", comment: ""),
            arguments: [response.course.displayPrice ?? "N/A"]
        )

        self.viewController?.displayModal(
            viewModel: .init(
                title: title,
                subtitle: NSLocalizedString("LessonFinishedDemoPanModalSubtitle", comment: ""),
                actionButtonTitle: actionButtonTitle
            )
        )
    }
}
