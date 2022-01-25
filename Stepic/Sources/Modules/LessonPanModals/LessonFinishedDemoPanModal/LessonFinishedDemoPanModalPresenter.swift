import UIKit

protocol LessonFinishedDemoPanModalPresenterProtocol {
    func presentModal(response: LessonFinishedDemoPanModal.ModalLoad.Response)
}

final class LessonFinishedDemoPanModalPresenter: LessonFinishedDemoPanModalPresenterProtocol {
    weak var viewController: LessonFinishedDemoPanModalViewControllerProtocol?

    func presentModal(response: LessonFinishedDemoPanModal.ModalLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makeViewModel(
                course: data.course,
                section: data.section,
                coursePurchaseFlow: data.coursePurchaseFlow,
                mobileTier: data.mobileTier
            )
            self.viewController?.displayModal(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayModal(viewModel: .init(state: .error))
        }
    }

    // MARK: Private API

    private func makeViewModel(
        course: Course,
        section: Section,
        coursePurchaseFlow: CoursePurchaseFlowType,
        mobileTier: MobileTierPlainObject?
    ) -> LessonFinishedDemoPanModalViewModel {
        let title = String(
            format: NSLocalizedString("LessonFinishedDemoPanModalTitle", comment: ""),
            arguments: [section.title]
        )

        let displayPrice: String? = {
            switch coursePurchaseFlow {
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

        return LessonFinishedDemoPanModalViewModel(
            title: title,
            subtitle: NSLocalizedString("LessonFinishedDemoPanModalSubtitle", comment: ""),
            actionButtonTitle: actionButtonTitle
        )
    }
}
