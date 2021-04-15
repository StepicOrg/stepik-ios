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
    }

    enum ViewControllerState {
        case loading
        case result(data: DebugMenuViewModel)
    }
}
