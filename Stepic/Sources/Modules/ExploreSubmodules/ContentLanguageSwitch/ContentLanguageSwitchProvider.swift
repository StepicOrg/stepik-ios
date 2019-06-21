import Foundation
import PromiseKit

protocol ContentLanguageSwitchProviderProtocol {
    func fetchAvailableLanguages() -> Guarantee<[ContentLanguage]>
    func fetchCurrentLanguage() -> Guarantee<ContentLanguage>

    func setGlobalContentLanguage(_ contentLanguage: ContentLanguage)
}

final class ContentLanguageSwitchProvider: ContentLanguageSwitchProviderProtocol {
    private let contentLanguageService: ContentLanguageServiceProtocol

    init(contentLanguageService: ContentLanguageServiceProtocol) {
        self.contentLanguageService = contentLanguageService
    }

    func fetchAvailableLanguages() -> Guarantee<[ContentLanguage]> {
        return Guarantee { seal in
            seal(ContentLanguage.supportedLanguages)
        }
    }

    func fetchCurrentLanguage() -> Guarantee<ContentLanguage> {
        return Guarantee { seal in
            seal(self.contentLanguageService.globalContentLanguage)
        }
    }

    func setGlobalContentLanguage(_ contentLanguage: ContentLanguage) {
        self.contentLanguageService.globalContentLanguage = contentLanguage
    }
}
