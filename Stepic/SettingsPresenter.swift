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

class SettingsPresenter {
    weak var view: SettingsView?

    var menu: [SettingsMenuBlock] = [
        .videoHeader,
        .onlyWifiSwitch,
        .loadedVideoQuality,
        .onlineVideoQuality,
        .codeEditorSettingsHeader,
        .codeEditorSettings,
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
        view?.presentAuth()
    }

    func changeVideoWifiReachability(to isReachable: Bool) {
        ConnectionHelper.shared.reachableOnWWAN = isReachable
    }

    func changeAdaptiveModeEnabled(to isEnabled: Bool) {
        AdaptiveStorageManager.shared.isAdaptiveModeEnabled = isEnabled
    }
}
