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
                mobileTier: data.mobileTier,
                shouldCheckIAPPurchaseSupport: data.shouldCheckIAPPurchaseSupport,
                isSupportedIAPPurchase: data.isSupportedIAPPurchase
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
        mobileTier: MobileTierPlainObject?,
        shouldCheckIAPPurchaseSupport: Bool,
        isSupportedIAPPurchase: Bool
    ) -> LessonFinishedDemoPanModalViewModel {
        let title = String(
            format: NSLocalizedString("LessonFinishedDemoPanModalTitle", comment: ""),
            arguments: [section.title]
        )

        let displayPrice: String = { () -> String? in
            switch coursePurchaseFlow {
            case .web:
                return course.displayPriceIAP ?? course.displayPrice
            case .iap:
                return mobileTier?.priceTierDisplayPrice ?? course.displayPrice
            }
        }() ?? "N/A"
        let promoDisplayPrice: String? = {
            switch coursePurchaseFlow {
            case .web:
                return nil
            case .iap:
                return mobileTier?.promoTierDisplayPrice
            }
        }()

        let unsupportedIAPPurchaseText = shouldCheckIAPPurchaseSupport && !isSupportedIAPPurchase
            ? NSLocalizedString("CourseInfoPurchaseModalPurchaseErrorUnsupportedCourseMessage", comment: "")
            : nil

        return LessonFinishedDemoPanModalViewModel(
            title: title,
            subtitle: NSLocalizedString("LessonFinishedDemoPanModalSubtitle", comment: ""),
            displayPrice: displayPrice,
            promoDisplayPrice: promoDisplayPrice,
            unsupportedIAPPurchaseText: unsupportedIAPPurchaseText
        )
    }
}
