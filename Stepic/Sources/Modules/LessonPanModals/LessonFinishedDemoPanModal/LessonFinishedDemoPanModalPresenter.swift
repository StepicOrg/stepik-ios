import UIKit

protocol LessonFinishedDemoPanModalPresenterProtocol {
    func presentModal(response: LessonFinishedDemoPanModal.ModalLoad.Response)
    func presentAddCourseToWishlistResult(response: LessonFinishedDemoPanModal.AddCourseToWishlist.Response)
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
                isSupportedIAPPurchase: data.isSupportedIAPPurchase,
                isAddingToWishlist: false
            )
            self.viewController?.displayModal(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayModal(viewModel: .init(state: .error))
        }
    }

    func presentAddCourseToWishlistResult(response: LessonFinishedDemoPanModal.AddCourseToWishlist.Response) {
        let isAddingToWishlist: Bool = {
            switch response.state {
            case .loading:
                return true
            case .error, .success:
                return false
            }
        }()
        let viewModel = self.makeViewModel(
            course: response.data.course,
            section: response.data.section,
            coursePurchaseFlow: response.data.coursePurchaseFlow,
            mobileTier: response.data.mobileTier,
            shouldCheckIAPPurchaseSupport: response.data.shouldCheckIAPPurchaseSupport,
            isSupportedIAPPurchase: response.data.isSupportedIAPPurchase,
            isAddingToWishlist: isAddingToWishlist
        )

        switch response.state {
        case .loading:
            self.viewController?.displayAddCourseToWishlistResult(viewModel: .init(state: .loading(viewModel)))
        case .error:
            let message = NSLocalizedString("CourseInfoAddToWishlistFailureMessage", comment: "")
            self.viewController?.displayAddCourseToWishlistResult(
                viewModel: .init(state: .error(message: message, data: viewModel))
            )
        case .success:
            let message = NSLocalizedString("CourseInfoAddToWishlistSuccessMessage", comment: "")
            self.viewController?.displayAddCourseToWishlistResult(
                viewModel: .init(state: .success(message: message, data: viewModel))
            )
        }
    }

    // MARK: Private API

    private func makeViewModel(
        course: Course,
        section: Section,
        coursePurchaseFlow: CoursePurchaseFlowType,
        mobileTier: MobileTierPlainObject?,
        shouldCheckIAPPurchaseSupport: Bool,
        isSupportedIAPPurchase: Bool,
        isAddingToWishlist: Bool
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

        let wishlistTitle: String = {
            if isAddingToWishlist {
                return NSLocalizedString("CourseInfoPurchaseModalWishlistButtonAddingToWishlistTitle", comment: "")
            }
            return course.isInWishlist
                ? NSLocalizedString("CourseInfoPurchaseModalWishlistButtonInWishlistTitle", comment: "")
                : NSLocalizedString("CourseInfoPurchaseModalWishlistButtonAddToWishlistTitle", comment: "")
        }()

        let unsupportedIAPPurchaseText = shouldCheckIAPPurchaseSupport && !isSupportedIAPPurchase
            ? NSLocalizedString("CourseInfoPurchaseModalPurchaseErrorUnsupportedCourseMessage", comment: "")
            : nil

        return LessonFinishedDemoPanModalViewModel(
            title: title,
            subtitle: NSLocalizedString("LessonFinishedDemoPanModalSubtitle", comment: ""),
            displayPrice: displayPrice,
            promoDisplayPrice: promoDisplayPrice,
            wishlistTitle: wishlistTitle,
            isInWishlist: course.isInWishlist,
            isAddingToWishlist: isAddingToWishlist,
            unsupportedIAPPurchaseText: unsupportedIAPPurchaseText
        )
    }
}
