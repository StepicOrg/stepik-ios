import Foundation
import PromiseKit

protocol SettingsProviderProtocol: AnyObject {
    // DownloadVideoQuality
    var globalDownloadVideoQuality: DownloadVideoQuality { get set }
    var availableDownloadVideoQualities: [DownloadVideoQuality] { get }
    // StreamVideoQuality
    var globalStreamVideoQuality: StreamVideoQuality { get set }
    var availableStreamVideoQualities: [StreamVideoQuality] { get }
    // ContentLanguage
    var globalContentLanguage: ContentLanguage { get set }
    var availableContentLanguages: [ContentLanguage] { get }
    // StepFontSize
    var globalStepFontSize: StepFontSize { get set }
    var availableStepFontSizes: [StepFontSize] { get }

    var isAutoplayEnabled: Bool { get set }
    var isAdaptiveModeEnabled: Bool { get set }

    func deleteAllDownloadedContent() -> Promise<Void>
}

final class SettingsProvider: SettingsProviderProtocol {
    private let downloadVideoQualityStorageManager: DownloadVideoQualityStorageManagerProtocol
    private let streamVideoQualityStorageManager: StreamVideoQualityStorageManagerProtocol
    private let contentLanguageService: ContentLanguageServiceProtocol
    private let stepFontSizeStorageManager: StepFontSizeStorageManagerProtocol
    private let autoplayStorageManager: AutoplayStorageManagerProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol

    private var downloadsProvider: DownloadsProviderProtocol

    var globalDownloadVideoQuality: DownloadVideoQuality {
        get {
            self.downloadVideoQualityStorageManager.globalDownloadVideoQuality
        }
        set {
            self.downloadVideoQualityStorageManager.globalDownloadVideoQuality = newValue
        }
    }

    var availableDownloadVideoQualities: [DownloadVideoQuality] { DownloadVideoQuality.allCases }

    var globalStreamVideoQuality: StreamVideoQuality {
        get {
            self.streamVideoQualityStorageManager.globalStreamVideoQuality
        }
        set {
            self.streamVideoQualityStorageManager.globalStreamVideoQuality = newValue
        }
    }

    var availableStreamVideoQualities: [StreamVideoQuality] { StreamVideoQuality.allCases }

    var globalContentLanguage: ContentLanguage {
        get {
            self.contentLanguageService.globalContentLanguage
        }
        set {
            self.contentLanguageService.globalContentLanguage = newValue
        }
    }

    var availableContentLanguages: [ContentLanguage] { ContentLanguage.supportedLanguages }

    var globalStepFontSize: StepFontSize {
        get {
            self.stepFontSizeStorageManager.globalStepFontSize
        }
        set {
            self.stepFontSizeStorageManager.globalStepFontSize = newValue
        }
    }

    var availableStepFontSizes: [StepFontSize] { StepFontSize.allCases }

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
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        downloadsProvider: DownloadsProviderProtocol
    ) {
        self.downloadVideoQualityStorageManager = downloadVideoQualityStorageManager
        self.streamVideoQualityStorageManager = streamVideoQualityStorageManager
        self.contentLanguageService = contentLanguageService
        self.stepFontSizeStorageManager = stepFontSizeStorageManager
        self.autoplayStorageManager = autoplayStorageManager
        self.adaptiveStorageManager = adaptiveStorageManager
        self.downloadsProvider = downloadsProvider
    }

    func deleteAllDownloadedContent() -> Promise<Void> {
        self.downloadsProvider.fetchCachedCourses().then { cachedCourses in
            self.downloadsProvider.deleteCachedCourses(cachedCourses)
        }
    }
}
