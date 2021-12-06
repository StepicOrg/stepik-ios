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

    /// Add course to withlist
    enum WishlistMainAction {
        struct Request {}
    }

    /// Add course to withlist result
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

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: CourseInfoPurchaseModalViewModel)
    }

    enum CheckPromoCodeState {
        case error
        case result(data: CourseInfoPurchaseModalPriceViewModel)
    }
}
