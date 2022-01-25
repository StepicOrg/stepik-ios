import Foundation

enum LessonFinishedDemoPanModal {
    struct ModalData {
        let course: Course
        let section: Section
        let coursePurchaseFlow: CoursePurchaseFlowType
        let mobileTier: MobileTierPlainObject?
        let shouldCheckIAPPurchaseSupport: Bool
        let isSupportedIAPPurchase: Bool
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

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: LessonFinishedDemoPanModalViewModel)
    }
}
