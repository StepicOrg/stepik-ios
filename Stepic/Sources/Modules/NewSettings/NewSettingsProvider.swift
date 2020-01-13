import Foundation
import PromiseKit

protocol NewSettingsProviderProtocol {
    var downloadVideoQuality: DownloadVideoQuality { get set }
    var streamVideoQuality: StreamVideoQuality { get set }
    var contentLanguage: ContentLanguage { get set }
    var stepFontSize: FontSize { get set }
    var isAutoplayEnabled: Bool { get set }
    var isAdaptiveModeEnabled: Bool { get set }
}

final class NewSettingsProvider: NewSettingsProviderProtocol {
    private let downloadVideoQualityStorageManager: DownloadVideoQualityStorageManagerProtocol
    private let streamVideoQualityStorageManager: StreamVideoQualityStorageManagerProtocol
    private let contentLanguageService: ContentLanguageServiceProtocol
    private let stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol
    private let autoplayStorageManager: AutoplayStorageManagerProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol

    var downloadVideoQuality: DownloadVideoQuality {
        get {
            self.downloadVideoQualityStorageManager.downloadVideoQuality
        }
        set {
            self.downloadVideoQualityStorageManager.downloadVideoQuality = newValue
        }
    }

    var streamVideoQuality: StreamVideoQuality {
        get {
            self.streamVideoQualityStorageManager.streamVideoQuality
        }
        set {
            self.streamVideoQualityStorageManager.streamVideoQuality = newValue
        }
    }

    var contentLanguage: ContentLanguage {
        get {
            self.contentLanguageService.globalContentLanguage
        }
        set {
            self.contentLanguageService.globalContentLanguage = newValue
        }
    }

    var stepFontSize: FontSize {
        get {
            self.stepFontSizeStorageManager.globalStepFontSize
        }
        set {
            self.stepFontSizeStorageManager.globalStepFontSize = newValue
        }
    }

    var isAutoplayEnabled: Bool {
        get {
            self.autoplayStorageManager.isAutoplayEnabled
        }
        set {
            self.autoplayStorageManager.isAutoplayEnabled = newValue
        }
    }

    var isAdaptiveModeEnabled: Bool {
        get {
            self.adaptiveStorageManager.isAdaptiveModeEnabled
        }
        set {
            self.adaptiveStorageManager.isAdaptiveModeEnabled = newValue
        }
    }

    init(
        downloadVideoQualityStorageManager: DownloadVideoQualityStorageManagerProtocol,
        streamVideoQualityStorageManager: StreamVideoQualityStorageManagerProtocol,
        contentLanguageService: ContentLanguageServiceProtocol,
        stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol,
        autoplayStorageManager: AutoplayStorageManagerProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol
    ) {
        self.downloadVideoQualityStorageManager = downloadVideoQualityStorageManager
        self.streamVideoQualityStorageManager = streamVideoQualityStorageManager
        self.contentLanguageService = contentLanguageService
        self.stepFontSizeStorageManager = stepFontSizeStorageManager
        self.autoplayStorageManager = autoplayStorageManager
        self.adaptiveStorageManager = adaptiveStorageManager
    }
}
