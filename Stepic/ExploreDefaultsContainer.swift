//
//  ExploreDefaultsContainer.swift
//  Stepic
//
//  Created by Ostrenkiy on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class ExploreDefaultsContainer {
    private let shouldDisplayContentLanguageWidgetKey = "shouldDisplayContentLanguageWidget"
    let defaults = UserDefaults.standard

    var shouldDisplayContentLanguageWidget: Bool {
        get {
            return defaults.value(forKey: shouldDisplayContentLanguageWidgetKey) as? Bool ?? true
        }
        set {
            defaults.set(newValue, forKey: shouldDisplayContentLanguageWidgetKey)
        }
    }
}
