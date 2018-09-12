//
//  ContentLanguageSwitchProvider.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol ContentLanguageSwitchProviderProtocol {
    func fetchAvailableLanguages() -> Guarantee<[ContentLanguage]>
    func fetchCurrentLanguage() -> Guarantee<ContentLanguage>
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
}
