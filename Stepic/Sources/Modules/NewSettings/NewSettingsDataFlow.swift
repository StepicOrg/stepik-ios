import Foundation

enum NewSettings {
    /// Present settings
    enum SettingsLoad {
        struct Request { }

        struct Response {
            let data: SettingsData
        }

        struct ViewModel {
            let viewModel: NewSettingsViewModel
        }
    }

    /// Presents download video quality setting screen.
    enum DownloadVideoQualityPresentation {
        struct Request { }

        struct Response {
            let availableDownloadVideoQualities: [DownloadVideoQuality]
            let globalDownloadVideoQuality: DownloadVideoQuality
        }

        struct ViewModel {
            let settingDescription: SettingDescription
        }
    }

    /// Updates global download video quality setting.
    enum DownloadVideoQualityUpdate {
        struct Request {
            let setting: SettingDescription.Setting
        }
    }

    /// Presents stream video quality setting screen.
    enum StreamVideoQualityPresentation {
        struct Request { }

        struct Response {
            let availableStreamVideoQualities: [StreamVideoQuality]
            let globalStreamVideoQuality: StreamVideoQuality
        }

        struct ViewModel {
            let settingDescription: SettingDescription
        }
    }

    /// Updates global stream video quality setting.
    enum StreamVideoQualityUpdate {
        struct Request {
            let setting: SettingDescription.Setting
        }
    }

    /// Presents content language setting screen.
    enum ContentLanguagePresentation {
        struct Request { }

        struct Response {
            let availableContentLanguages: [ContentLanguage]
            let globalContentLanguage: ContentLanguage
        }

        struct ViewModel {
            let settingDescription: SettingDescription
        }
    }

    /// Updates global content language setting.
    enum ContentLanguageUpdate {
        struct Request {
            let setting: SettingDescription.Setting
        }
    }

    /// Presents step font size setting screen.
    enum StepFontSizePresentation {
        struct Request { }

        struct Response {
            let availableStepFontSizes: [StepFontSize]
            let globalStepFontSize: StepFontSize
        }

        struct ViewModel {
            let settingDescription: SettingDescription
        }
    }

    /// Updates global step font size setting.
    enum StepFontSizeUpdate {
        struct Request {
            let setting: SettingDescription.Setting
        }
    }

    /// Deletes all downloaded content.
    enum DeleteAllContent {
        struct Request { }

        struct Response {
            let isSuccessful: Bool
        }

        struct ViewModel {
            let isSuccessful: Bool
        }
    }

    /// Handle HUD
    enum BlockingWaitingIndicatorUpdate {
        struct Response {
            let shouldDismiss: Bool
        }

        struct ViewModel {
            let shouldDismiss: Bool
        }
    }

    // MARK: - Common Types

    struct SettingsData {
        let downloadVideoQuality: DownloadVideoQuality
        let streamVideoQuality: StreamVideoQuality
        let contentLanguage: ContentLanguage
        let stepFontSize: StepFontSize
        let isAutoplayEnabled: Bool
        let isAdaptiveModeEnabled: Bool
    }

    struct SettingDescription {
        let settings: [Setting]
        let currentSetting: Setting?

        struct Setting: UniqueIdentifiable {
            let uniqueIdentifier: UniqueIdentifierType
            let title: String
        }
    }
}
