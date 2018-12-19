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

    private var menu: [SettingsMenuBlock] = [
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
        .emptyHeader,
        .downloads,
        .logout
    ]

    private var staffMenu: [SettingsMenuBlock] = [
        .staffHeader,
        .splitTestGroup
    ]

    init(view: SettingsView) {
        self.view = view
        self.addStaffMenuIfAllowed()
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

    private func addStaffMenuIfAllowed() {
        let isStaff = true
        // TODO: AuthInfo.shared.user?.profileEntity?.isStaff
        if isStaff {
            self.menu.insert(contentsOf: self.staffMenu, at: 0)
        }
    }
}
