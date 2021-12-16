import Foundation

enum CourseInfoPurchaseModal {
    struct ModalData {
        let course: Course
        let mobileTier: MobileTierPlainObject
    }

    /// Load & show modal
    enum ModalLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<ModalData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Calculate mobile tier with promo code
    enum CheckPromoCode {
        struct Request {
            let promoCode: String
        }

        struct Response {
            let result: StepikResult<ModalData>
        }

        struct ViewModel {
            let state: CheckPromoCodeState
        }
    }

    /// Handle promo code input changed
    enum PromoCodeDidChange {
        struct Request {
            let promoCode: String
        }
    }

    /// Add course to wishlist
    enum WishlistMainAction {
        struct Request {}
    }

    /// Add course to wishlist result
    enum AddCourseToWishlist {
        struct Response {
            let state: State

            enum State {
                case loading
                case error
                case success
            }
        }

        struct ViewModel {
            let state: State

            enum State {
                case loading(CourseInfoPurchaseModalWishlistViewModel)
                case error(message: String)
                case result(message: String, data: CourseInfoPurchaseModalWishlistViewModel)
            }
        }
    }

    /// Perform continue learning action after success purchase
    enum StartLearningPresentation {
        struct Request {}
    }

    /// Course purchase flow
    enum PurchaseCourse {
        struct Request {}

        struct Response {
            let state: State

            enum State {
                case inProgress
                case error(error: IAPService.Error, modalData: ModalData)
                case success
            }
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Try to restore course purchase
    enum RestorePurchase {
        struct Request {}

        struct Response {
            let state: State

            enum State {
                case inProgress
                case error
                case success
            }
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Send analytics event
    enum RevealPromoCodeInput {
        struct Request {}
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: CourseInfoPurchaseModalViewModel)
        case purchaseInProgress
        case purchaseErrorAppStore(errorDescription: String?, modalData: CourseInfoPurchaseModalViewModel)
        case purchaseErrorStepik
        case purchaseSuccess
        case restorePurchaseInProgress
        case restorePurchaseError(errorDescription: String?)
        case restorePurchaseSuccess
    }

    enum CheckPromoCodeState {
        case error
        case result(data: CourseInfoPurchaseModalPriceViewModel)
    }
}
