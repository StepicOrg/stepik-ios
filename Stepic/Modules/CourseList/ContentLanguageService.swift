//
//  ContentLanguageService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol ContentLanguageServiceProtocol: class {
    var globalContentLanguage: ContentLanguage { get set }
}

final class ContentLanguageService: ContentLanguageServiceProtocol {
    private static let sharedContentLanguageKey = "contentLanguage"

    // TODO: Replace with cache driver
    var globalContentLanguage: ContentLanguage {
        set {
            UserDefaults.standard.setValue(
                newValue.languageString,
                forKey: ContentLanguageService.sharedContentLanguageKey
            )
        }
        get {
            guard let cachedValue = UserDefaults.standard.value(
                forKey: ContentLanguageService.sharedContentLanguageKey
            ) as? String else {
                self.globalContentLanguage = self.appInterfaceLanguage
                return self.appInterfaceLanguage
            }

            return ContentLanguage(languageString: cachedValue)
        }
    }

    private var appInterfaceLanguage: ContentLanguage {
        let currentLanguageString = Bundle.main.preferredLocalizations.first ?? "en"
        return ContentLanguage(languageString: currentLanguageString)
    }
}
