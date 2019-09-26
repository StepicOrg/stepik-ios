//
//  SettingsPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol SettingsView: class {
    func setMenu(menuIDs: [SettingsMenuBlock])

    func presentAuth()
}

final class SettingsPresenter {
    weak var view: SettingsView?

    var menu: [SettingsMenuBlock] = [
        .videoHeader,
        .downloads,
        .loadingVideoQuality,
        .onlineVideoQuality,
        .appearanceHeader,
        .codeEditorSettings,
        .stepFontSize,
        .languageSettingsHeader,
        .contentLanguage,
        .adaptiveHeader,
        .adaptiveModeSwitch,
        .logout
    ]

    init(view: SettingsView) {
        self.view = view
        view.setMenu(menuIDs: self.menu)
    }

    // MARK: - Menu blocks

    func logout() {
        AuthInfo.shared.token = nil
        self.view?.presentAuth()
    }

    func changeAdaptiveModeEnabled(to isEnabled: Bool) {
        AdaptiveStorageManager.shared.isAdaptiveModeEnabled = isEnabled
    }
}
