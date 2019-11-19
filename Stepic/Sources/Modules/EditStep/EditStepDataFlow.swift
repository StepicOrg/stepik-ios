import Foundation

enum EditStep {
    // MARK: - Use cases -

    enum LoadStepSource {
        struct Request { }

        struct Data {
            let originalText: String
            let currentText: String
        }

        struct Response {
            let data: Result<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: - States

    enum ViewControllerState {
        case loading
        case error
        case result(data: EditStepViewModel)
    }
}
