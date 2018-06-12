//
//  SettingsMenuBlock.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum SettingsMenuBlock: String, Equatable {
    typealias RawValue = String

    case videoHeader = "video_header"
    case onlyWifiSwitch = "only_wifi_switch"
    case loadedVideoQuality = "loaded_video_quality"
    case onlineVideoQuality = "online_video_quality"
    case adaptiveHeader = "adaptive_header"
    case adaptiveModeSwitch = "use_adaptive_mode"
    case codeEditorSettingsHeader = "code_editor_header"
    case codeEditorSettings = "code_editor_settings"
    case downloads = "downloads"
    case logout = "logout"
    case emptyHeader = "empty_header"
    case languageSettingsHeader = "language_settings"
    case contentLanguage = "content_language_settings"

    static func == (lhs: SettingsMenuBlock, rhs: SettingsMenuBlock) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
