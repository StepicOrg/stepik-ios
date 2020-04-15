//
//  CodeEditorPreferencesContainer.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.04.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "Legacy class")
final class CodeEditorPreferencesContainer {
    private let defaults = UserDefaults.standard

    private let themeKey = "themeKey"
    private let fontSizeKey = "fontSizeKey"

    var theme: String {
        get {
            if let value = defaults.value(forKey: themeKey) as? String {
                return value
            } else {
                self.theme = "xcode"
                return "xcode"
            }
        }

        set {
            defaults.set(newValue, forKey: themeKey)
        }
    }

    var fontSize: Int {
        get {
            if let value = defaults.value(forKey: fontSizeKey) as? Int {
                return value
            } else {
                let value = DeviceInfo.current.isPad ? 17 : 15
                self.fontSize = value
                return value
            }
        }

        set {
            defaults.set(newValue, forKey: fontSizeKey)
        }
    }
}
