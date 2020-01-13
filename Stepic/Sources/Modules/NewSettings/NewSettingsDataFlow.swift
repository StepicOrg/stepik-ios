import Foundation

enum NewSettings {
    /// Present settings
    enum SettingsLoad {
        struct Request { }

        struct Response {
            let downloadVideoQuality: DownloadVideoQuality
            let streamVideoQuality: StreamVideoQuality
            let contentLanguage: ContentLanguage
            let stepFontSize: FontSize
            let isAutoplayEnabled: Bool
            let isAdaptiveModeEnabled: Bool
        }

        struct ViewModel {
            let viewModel: NewSettingsViewModel
        }
    }
}
