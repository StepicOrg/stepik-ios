import Foundation

enum SettingsStepFontSize {
    // MARK: Common structs

    struct FontSizeInfo {
        let availableFontSizes: [(UniqueIdentifierType, FontSize)]
        let activeFontSize: FontSize
    }

    // MARK: Use cases

    /// Show font sizes
    enum FontSizesLoad {
        struct Request { }

        struct Response {
            let result: FontSizeInfo
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Change font size
    enum FontSizeSelection {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let result: FontSizeInfo
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [SettingsStepFontSizeViewModel])
        case error(message: String)
    }
}
