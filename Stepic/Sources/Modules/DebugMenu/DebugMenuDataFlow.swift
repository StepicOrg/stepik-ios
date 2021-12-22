import Foundation

enum DebugMenu {
    enum DebugDataLoad {
        struct Request {}

        struct Response {
            let data: DebugData
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    struct DebugData {
        let fcmRegistrationToken: StepikResult<String>
        let iapCreateCoursePaymentDelay: Double?
    }

    enum IAPFinishAllTransactions {
        struct Request {}

        struct Response {
            let finishedCount: Int
        }

        struct ViewModel {
            let message: String
        }
    }

    enum IAPUpdateCreateCoursePaymentDelay {
        struct Request {
            let input: String?
        }
    }

    enum ViewControllerState {
        case loading
        case result(data: DebugMenuViewModel)
    }
}
