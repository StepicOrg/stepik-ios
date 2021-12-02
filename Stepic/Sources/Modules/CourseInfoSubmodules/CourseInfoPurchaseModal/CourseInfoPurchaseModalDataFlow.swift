import Foundation

enum CourseInfoPurchaseModal {
    enum ModalLoad {
        struct Request {}

        struct Response {
            struct Data {
                let course: Course
                let mobileTier: MobileTierPlainObject
            }

            var result: StepikResult<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    enum ViewControllerState {
        case loading
        case error
        case result(data: CourseInfoPurchaseModalViewModel)
    }
}
