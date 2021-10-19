import Foundation

enum CourseInfoPurchaseModal {
    enum ModalLoad {
        struct Request {}

        struct Response {}

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    enum ViewControllerState {
        case loading
        case result(data: CourseInfoPurchaseModalViewModel)
    }
}
