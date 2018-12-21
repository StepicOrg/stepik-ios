//
// SettingsMenuBlockFactory.swift
// stepik-ios
//
// Created by Ivan Magda on 2018-12-21.
// Copyright 2018 Stepik. All rights reserved.
//

import UIKit

struct SettingsMenuBlockFactory {
    private let onTouch: () -> Void
    private let onSwitch: (Bool) -> Void

    init(onTouch: @escaping () -> Void, onSwitch: @escaping (Bool) -> Void) {
        self.onTouch = onTouch
        self.onSwitch = onSwitch
    }

    func makeMenuBlock(for id: SettingsMenuBlock) -> MenuBlock {
        switch id {
        case .staffHeader:
            return self.makeHeader(id: id, localizedKey: "StaffSettingsTitle")
        case .splitTestGroup:
            return self.makeTransition(id: id, localizedKey: "StaffActiveSplitTestGroupPreference")
        case .videoHeader:
            return self.makeHeader(id: id, localizedKey: "Video")
        case .onlyWifiSwitch:
            return self.makeSwitch(
                id: id,
                localizedKey: "WiFiLoadPreference",
                isOn: !ConnectionHelper.shared.reachableOnWWAN
            )
        case .loadedVideoQuality:
            return self.makeTransition(id: id, localizedKey: "LoadingVideoQualityPreference")
        case .onlineVideoQuality:
            return self.makeTransition(id: id, localizedKey: "WatchingVideoQualityPreference")
        case .codeEditorSettingsHeader:
            return self.makeHeader(id: id, localizedKey: "CodeEditorTitle")
        case .codeEditorSettings:
            return self.makeTransition(id: id, localizedKey: "CodeEditorSettingsTitle")
        case .languageSettingsHeader:
            return self.makeHeader(id: id, localizedKey: "LanguageSettingsTitle")
        case .contentLanguage:
            return self.makeTransition(id: id, localizedKey: "ContentLanguagePreference")
        case .adaptiveHeader:
            return self.makeHeader(id: id, localizedKey: "AdaptivePreferencesTitle")
        case .adaptiveModeSwitch:
            return self.makeSwitch(
                id: id,
                localizedKey: "UseAdaptiveModePreference",
                isOn: AdaptiveStorageManager.shared.isAdaptiveModeEnabled
            )
        case .emptyHeader:
            return self.makeHeader(id: id, localizedKey: "")
        case .downloads:
            return self.makeTransition(id: id, localizedKey: "Downloads")
        case .logout:
            let block = self.makeTransition(id: id, localizedKey: "Logout")
            block.titleColor = UIColor(red: 200 / 255, green: 40 / 255, blue: 80 / 255, alpha: 1)
            return block
        }
    }

    private func makeHeader(
        id: SettingsMenuBlock,
        localizedKey key: String
    ) -> HeaderMenuBlock {
        return HeaderMenuBlock(
            id: id.rawValue,
            title: NSLocalizedString(key, comment: "")
        )
    }

    private func makeTransition(
        id: SettingsMenuBlock,
        localizedKey key: String
    ) -> TransitionMenuBlock {
        let transitionMenuBlock = TransitionMenuBlock(
            id: id.rawValue,
            title: NSLocalizedString(key, comment: "")
        )
        transitionMenuBlock.onTouch = self.onTouch

        return transitionMenuBlock
    }

    private func makeSwitch(
        id: SettingsMenuBlock,
        localizedKey key: String,
        isOn: Bool
    ) -> SwitchMenuBlock {
        let switchMenuBlock = SwitchMenuBlock(
            id: id.rawValue,
            title: NSLocalizedString(key, comment: ""),
            isOn: isOn
        )
        switchMenuBlock.onSwitch = self.onSwitch

        return switchMenuBlock
    }
}
