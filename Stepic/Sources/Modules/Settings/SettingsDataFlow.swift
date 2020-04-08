import Foundation

enum Settings {
    /// Present settings
    enum SettingsLoad {
        struct Request {}

        struct Response {
            let data: SettingsData
        }

        struct ViewModel {
            let viewModel: SettingsViewModel
        }
    }

    /// Presents download video quality setting screen.
    enum DownloadVideoQualitySettingPresentation {
        struct Request {}

        struct Response {
            let availableDownloadVideoQualities: [DownloadVideoQuality]
            let globalDownloadVideoQuality: DownloadVideoQuality
        }

        struct ViewModel {
            let settingDescription: SettingDescription
        }
    }

    /// Updates global download video quality setting.
    enum DownloadVideoQualitySettingUpdate {
        struct Request {
            let setting: SettingDescription.Setting
        }
    }

    /// Presents stream video quality setting screen.
    enum StreamVideoQualitySettingPresentation {
        struct Request {}

        struct Response {
            let availableStreamVideoQualities: [StreamVideoQuality]
            let globalStreamVideoQuality: StreamVideoQuality
        }

        struct ViewModel {
            let settingDescription: SettingDescription
        }
    }

    /// Updates global stream video quality setting.
    enum StreamVideoQualitySettingUpdate {
        struct Request {
            let setting: SettingDescription.Setting
        }
    }

    /// Presents application theme setting screen.
    enum ApplicationThemeSettingPresentation {
        struct Request {}

        struct Response {
            let availableApplicationThemes: [ApplicationTheme]
            let currentApplicationTheme: ApplicationTheme
        }

        struct ViewModel {
            let settingDescription: SettingDescription
        }
    }

    /// Updates application theme setting.
    enum ApplicationThemeSettingUpdate {
        struct Request {
            let setting: SettingDescription.Setting
        }
    }

    /// Presents content language setting screen.
    enum ContentLanguageSettingPresentation {
        struct Request {}

        struct Response {
            let availableContentLanguages: [ContentLanguage]
            let globalContentLanguage: ContentLanguage
        }

        struct ViewModel {
            let settingDescription: SettingDescription
        }
    }

    /// Updates global content language setting.
    enum ContentLanguageSettingUpdate {
        struct Request {
            let setting: SettingDescription.Setting
        }
    }

    /// Presents step font size setting screen.
    enum StepFontSizeSettingPresentation {
        struct Request {}

        struct Response {
            let availableStepFontSizes: [StepFontSize]
            let globalStepFontSize: StepFontSize
        }

        struct ViewModel {
            let settingDescription: SettingDescription
        }
    }

    /// Updates global step font size setting.
    enum StepFontSizeSettingUpdate {
        struct Request {
            let setting: SettingDescription.Setting
        }
    }

    /// Updates global use mobile data for downloading setting.
    enum UseCellularDataForDownloadsSettingUpdate {
        struct Request {
            let isOn: Bool
        }
    }

    /// Updates global autoplay next video setting.
    enum AutoplayNextVideoSettingUpdate {
        struct Request {
            let isOn: Bool
        }
    }

    /// Updates global adaptive mode setting.
    enum AdaptiveModeSettingUpdate {
        struct Request {
            let isOn: Bool
        }
    }

    /// Deletes all downloaded content.
    enum DeleteAllContent {
        struct Request {}

        struct Response {
            let isSuccessful: Bool
        }

        struct ViewModel {
            let isSuccessful: Bool
        }
    }

    /// Transition to anonymous mode.
    enum AccountLogOut {
        struct Request {}
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
        let applicationTheme: ApplicationTheme
        let contentLanguage: ContentLanguage
        let stepFontSize: StepFontSize
        let shouldUseCellularDataForDownloads: Bool
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
