import Foundation

enum NewStep {
    enum StepLoad {
        struct Request { }

        struct Response {
            let result: Result<Step>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: Enums

    enum ViewControllerState {
        case loading
        case error
        case result(data: NewStepViewModel)
    }
}
