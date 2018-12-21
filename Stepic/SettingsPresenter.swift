//
//  SettingsPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol SettingsView: class {
    func setMenu(ids: [SettingsMenuBlock])
    func presentAuth()
}

final class SettingsPresenter {
    private static let userMenu: [SettingsMenuBlock] = [
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
    private static let staffMenu: [SettingsMenuBlock] = [
        .staffHeader,
        .splitTestGroup
    ]

    weak var view: SettingsView?

    init(view: SettingsView) {
        self.view = view
        self.setup()
    }

    // MARK: Public API

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

    // MARK: Private API

    private func setup() {
        let isStaff = AuthInfo.shared.user?.profileEntity?.isStaff ?? false
        let menuIds = isStaff
            ? SettingsPresenter.staffMenu + SettingsPresenter.userMenu
            : SettingsPresenter.userMenu

        self.view?.setMenu(ids: menuIds)
    }
}
