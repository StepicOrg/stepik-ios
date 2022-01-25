import Foundation

enum LessonFinishedDemoPanModal {
    struct ModalData {
        let course: Course
        let section: Section
        let coursePurchaseFlow: CoursePurchaseFlowType
        let mobileTier: MobileTierPlainObject?
    }

    enum ModalLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<ModalData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    enum MainModalAction {
        struct Request {}
    }

    enum WishlistMainAction {
        struct Request {}
    }

    /// Add course to wishlist result
    enum AddCourseToWishlist {
        struct Response {
            let state: State
            let data: ModalData

            enum State {
                case loading
                case error
                case success
            }
        }

        struct ViewModel {
            let state: State

            enum State {
                case loading(LessonFinishedDemoPanModalViewModel)
                case error(message: String, data: LessonFinishedDemoPanModalViewModel)
                case success(message: String, data: LessonFinishedDemoPanModalViewModel)
            }
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: LessonFinishedDemoPanModalViewModel)
    }
}
