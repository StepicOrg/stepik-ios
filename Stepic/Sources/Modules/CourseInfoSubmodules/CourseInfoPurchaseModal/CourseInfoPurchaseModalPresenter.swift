import UIKit

protocol CourseInfoPurchaseModalPresenterProtocol {
    func presentModal(response: CourseInfoPurchaseModal.ModalLoad.Response)
    func presentCheckPromoCodeResult(response: CourseInfoPurchaseModal.CheckPromoCode.Response)
    func presentAddCourseToWishlistResult(response: CourseInfoPurchaseModal.AddCourseToWishlist.Response)
    func presentPurchaseCourseResult(response: CourseInfoPurchaseModal.PurchaseCourse.Response)
    func presentRestorePurchaseResult(response: CourseInfoPurchaseModal.RestorePurchase.Response)
}

final class CourseInfoPurchaseModalPresenter: CourseInfoPurchaseModalPresenterProtocol {
    private let remoteConfig: RemoteConfig

    weak var viewController: CourseInfoPurchaseModalViewControllerProtocol?

    init(remoteConfig: RemoteConfig) {
        self.remoteConfig = remoteConfig
    }

    func presentModal(response: CourseInfoPurchaseModal.ModalLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makeModalViewModel(course: data.course, mobileTier: data.mobileTier)
            self.viewController?.displayModal(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayModal(viewModel: .init(state: .error))
        }
    }

    func presentCheckPromoCodeResult(response: CourseInfoPurchaseModal.CheckPromoCode.Response) {
        switch response.result {
        case .success(let data):
            let viewModel = self.makePriceViewModel(course: data.course, mobileTier: data.mobileTier)
            self.viewController?.displayCheckPromoCodeResult(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayCheckPromoCodeResult(viewModel: .init(state: .error))
        }
    }

    func presentAddCourseToWishlistResult(response: CourseInfoPurchaseModal.AddCourseToWishlist.Response) {
        switch response.state {
        case .loading:
            let viewModel = self.makeWishlistViewModel(isInWishlist: false, isLoading: true)
            self.viewController?.displayAddCourseToWishlistResult(viewModel: .init(state: .loading(viewModel)))
        case .error:
            let message = NSLocalizedString("CourseInfoAddToWishlistFailureMessage", comment: "")
            self.viewController?.displayAddCourseToWishlistResult(viewModel: .init(state: .error(message: message)))
        case .success:
            let message = NSLocalizedString("CourseInfoAddToWishlistSuccessMessage", comment: "")
            let viewModel = self.makeWishlistViewModel(isInWishlist: true, isLoading: false)
            self.viewController?.displayAddCourseToWishlistResult(
                viewModel: .init(state: .result(message: message, data: viewModel))
            )
        }
    }

    func presentPurchaseCourseResult(response: CourseInfoPurchaseModal.PurchaseCourse.Response) {
        guard let viewController = self.viewController else {
            return
        }

        switch response.state {
        case .inProgress:
            viewController.displayPurchaseCourseResult(viewModel: .init(state: .purchaseInProgress))
        case .error(let iapError, let modalData):
            let errorDescription: String? = {
                switch iapError {
                case .unsupportedCourse, .noProductIDsFound, .noProductsFound:
                    return NSLocalizedString(
                        "CourseInfoPurchaseModalPurchaseErrorUnsupportedCourseMessage",
                        comment: ""
                    )
                case .productsRequestFailed:
                    return NSLocalizedString(
                        "CourseInfoPurchaseModalPurchaseErrorProductsRequestFailedMessage",
                        comment: ""
                    )
                case .paymentFailed, .paymentNotAllowed, .paymentUserChanged:
                    return iapError.errorDescription
                case .paymentWasCancelled, .paymentReceiptValidationFailed:
                    return nil
                }
            }()

            if iapError == .paymentReceiptValidationFailed {
                viewController.displayPurchaseCourseResult(viewModel: .init(state: .purchaseErrorStepik))
            } else {
                let modalViewModel = self.makeModalViewModel(
                    course: modalData.course,
                    mobileTier: modalData.mobileTier
                )

                viewController.displayPurchaseCourseResult(
                    viewModel: .init(
                        state: .purchaseErrorAppStore(
                            errorDescription: errorDescription,
                            modalData: modalViewModel
                        )
                    )
                )

                if iapError == .paymentUserChanged {
                    DispatchQueue.main.async {
                        viewController.displayPurchaseCourseResult(viewModel: .init(state: .purchaseErrorStepik))
                    }
                }
            }
        case .success:
            viewController.displayPurchaseCourseResult(viewModel: .init(state: .purchaseSuccess))
        }
    }

    func presentRestorePurchaseResult(response: CourseInfoPurchaseModal.RestorePurchase.Response) {
        switch response.state {
        case .inProgress:
            self.viewController?.displayRestorePurchaseResult(viewModel: .init(state: .restorePurchaseInProgress))
        case .error:
            let errorDescription = IAPService.Error.paymentReceiptValidationFailed.errorDescription
            self.viewController?.displayRestorePurchaseResult(
                viewModel: .init(state: .restorePurchaseError(errorDescription: errorDescription))
            )
        case .success:
            self.viewController?.displayRestorePurchaseResult(viewModel: .init(state: .restorePurchaseSuccess))
        }
    }

    // MARK: Private API

    private func makeModalViewModel(
        course: Course,
        mobileTier: MobileTierPlainObject
    ) -> CourseInfoPurchaseModalViewModel {
        let priceViewModel = self.makePriceViewModel(course: course, mobileTier: mobileTier)
        let wishlistViewModel = self.makeWishlistViewModel(isInWishlist: course.isInWishlist)

        return CourseInfoPurchaseModalViewModel(
            courseTitle: course.title,
            courseCoverImageURL: URL(string: course.coverURLString),
            disclaimer: self.remoteConfig.purchaseFlowDisclaimer.trimmed(),
            price: priceViewModel,
            wishlist: wishlistViewModel
        )
    }

    private func makePriceViewModel(
        course: Course,
        mobileTier: MobileTierPlainObject
    ) -> CourseInfoPurchaseModalPriceViewModel {
        let displayPrice = mobileTier.priceTierDisplayPrice ?? course.displayPrice ?? "None"
        let promoDisplayPrice = mobileTier.promoTierDisplayPrice

        return CourseInfoPurchaseModalPriceViewModel(
            displayPrice: displayPrice,
            promoDisplayPrice: promoDisplayPrice,
            promoCodeName: mobileTier.promoCodeName
        )
    }

    private func makeWishlistViewModel(
        isInWishlist: Bool,
        isLoading: Bool = false
    ) -> CourseInfoPurchaseModalWishlistViewModel {
        let title: String = {
            if isLoading {
                return NSLocalizedString("CourseInfoPurchaseModalWishlistButtonAddingToWishlistTitle", comment: "")
            }
            return isInWishlist
                ? NSLocalizedString("CourseInfoPurchaseModalWishlistButtonInWishlistTitle", comment: "")
                : NSLocalizedString("CourseInfoPurchaseModalWishlistButtonAddToWishlistTitle", comment: "")
        }()

        return CourseInfoPurchaseModalWishlistViewModel(
            title: title,
            isInWishlist: isInWishlist,
            isLoading: isLoading
        )
    }
}
