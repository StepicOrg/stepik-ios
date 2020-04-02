import Foundation

enum EditStep {
    // MARK: Common structs

    struct StepSourceData {
        let originalText: String
        let currentText: String
    }

    // MARK: - Use cases -

    /// Load step source content
    enum LoadStepSource {
        struct Request { }

        struct Response {
            let data: StepikResult<StepSourceData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Handle user input changes
    enum UpdateStepText {
        struct Request {
            let text: String
        }

        struct Response {
            let data: StepSourceData
        }

        struct ViewModel {
            let viewModel: EditStepViewModel
        }
    }

    /// Try to update remote step source via API
    enum RemoteStepSourceUpdate {
        struct Request { }

        struct Response {
            let isSuccessful: Bool
        }

        struct ViewModel {
            let isSuccessful: Bool
            let feedback: String
        }
    }

    // MARK: - States

    enum ViewControllerState {
        case loading
        case error
        case result(data: EditStepViewModel)
    }
}
