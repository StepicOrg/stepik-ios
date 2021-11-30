import UIKit

protocol LessonFinishedDemoPanModalPresenterProtocol {
    func presentModal(response: LessonFinishedDemoPanModal.ModalLoad.Response)
}

final class LessonFinishedDemoPanModalPresenter: LessonFinishedDemoPanModalPresenterProtocol {
    weak var viewController: LessonFinishedDemoPanModalViewControllerProtocol?

    func presentModal(response: LessonFinishedDemoPanModal.ModalLoad.Response) {
        let course = response.course
        let mobileTier = response.mobileTier

        let title = String(
            format: NSLocalizedString("LessonFinishedDemoPanModalTitle", comment: ""),
            arguments: [response.section.title]
        )

        let displayPrice: String? = {
            switch response.coursePurchaseFlow {
            case .web:
                return course.displayPriceIAP ?? course.displayPrice
            case .iap:
                if let promoTierDisplayPrice = mobileTier?.promoTierDisplayPrice {
                    return promoTierDisplayPrice
                } else if let priceTierDisplayPrice = mobileTier?.priceTierDisplayPrice {
                    return priceTierDisplayPrice
                } else {
                    return course.displayPrice
                }
            }
        }()

        let actionButtonTitle = String(
            format: NSLocalizedString("WidgetButtonBuy", comment: ""),
            arguments: [displayPrice ?? "N/A"]
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
