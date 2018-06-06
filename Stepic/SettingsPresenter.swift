//
//  SettingsPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol SettingsView: class {
    func setMenu(menu: Menu)
    func changeVideoQuality(action: VideoQualityChoiceAction)
    func changeCodeEditorSettings()
    func changeContentLanguageSettings()

    func presentAuth()
    func navigateToDownloads()
}

class SettingsPresenter {
    weak var view: SettingsView?
    var menu: Menu = Menu(blocks: [])

    init(view: SettingsView) {
        self.view = view
        self.menu = buildSettingsMenu()
        view.setMenu(menu: self.menu)
    }

    private func buildSettingsMenu() -> Menu {
        let blocks = [
            buildTitleMenuBlock(id: BlockID.videoHeader, title: NSLocalizedString("Video", comment: "")),
            buildOnlyWifiSwitchBlock(),
            buildLoadedVideoQualityBlock(),
            buildOnlineVideoQualityBlock(),
            buildTitleMenuBlock(id: BlockID.codeEditorSettingsHeader, title: NSLocalizedString("CodeEditorTitle", comment: "")),
            buildCodeEditorSettingsBlock(),
            buildTitleMenuBlock(id: BlockID.languageSettingsHeader, title: NSLocalizedString("LanguageSettingsTitle", comment: "")),
            buildContentLanguageSettingsBlock(),
            buildTitleMenuBlock(id: BlockID.adaptiveHeader, title: NSLocalizedString("AdaptivePreferencesTitle", comment: "")),
            buildAdaptiveModeSwitchBlock(),
            buildTitleMenuBlock(id: BlockID.emptyHeader, title: ""),
            buildDownloadsTransitionBlock(),
            buildLogoutBlock()
        ]

        return Menu(blocks: blocks)
    }

    // MARK: - Menu blocks

    enum BlockID: String {
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
    }

    private func buildTitleMenuBlock(id: BlockID, title: String) -> HeaderMenuBlock {
        return HeaderMenuBlock(id: id.rawValue, title: title)
    }

    private func buildContentLanguageSettingsBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(id: BlockID.contentLanguage.rawValue, title: NSLocalizedString("ContentLanguagePreference", comment: ""))

        block.onTouch = {
            [weak self] in
            self?.view?.changeContentLanguageSettings()
        }

        return block
    }

    private func buildLoadedVideoQualityBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(id: BlockID.loadedVideoQuality.rawValue, title: NSLocalizedString("LoadingVideoQualityPreference", comment: ""))

        block.onTouch = {
            [weak self] in
            self?.view?.changeVideoQuality(action: .downloading)
        }

        return block
    }

    private func buildOnlineVideoQualityBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(id: BlockID.onlineVideoQuality.rawValue, title: NSLocalizedString("WatchingVideoQualityPreference", comment: ""))

        block.onTouch = {
            [weak self] in
            self?.view?.changeVideoQuality(action: .watching)
        }

        return block
    }

    private func buildOnlyWifiSwitchBlock() -> SwitchMenuBlock {
        let block = SwitchMenuBlock(id: BlockID.onlyWifiSwitch.rawValue, title: NSLocalizedString("WiFiLoadPreference", comment: ""), isOn: !ConnectionHelper.shared.reachableOnWWAN)

        block.onSwitch = {
            isOn in
            ConnectionHelper.shared.reachableOnWWAN = !isOn
        }

        return block
    }

    private func buildAdaptiveModeSwitchBlock() -> SwitchMenuBlock {
        let block = SwitchMenuBlock(id: BlockID.adaptiveModeSwitch.rawValue, title: NSLocalizedString("UseAdaptiveModePreference", comment: ""), isOn: AdaptiveStorageManager.shared.isAdaptiveModeEnabled)

        block.onSwitch = {
            isOn in
            AdaptiveStorageManager.shared.isAdaptiveModeEnabled = !AdaptiveStorageManager.shared.isAdaptiveModeEnabled
        }

        return block
    }

    private func buildCodeEditorSettingsBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(id: BlockID.codeEditorSettings.rawValue, title: NSLocalizedString("CodeEditorSettingsTitle", comment: ""))

        block.onTouch = {
            [weak self] in
            self?.view?.changeCodeEditorSettings()
        }

        return block
    }

    private func buildDownloadsTransitionBlock() -> TransitionMenuBlock {
        let block: TransitionMenuBlock = TransitionMenuBlock(id: BlockID.downloads.rawValue, title: NSLocalizedString("Downloads", comment: ""))

        block.onTouch = {
            [weak self] in
            self?.view?.navigateToDownloads()
        }

        return block
    }

    private func buildLogoutBlock() -> TransitionMenuBlock {
        let block: TransitionMenuBlock = TransitionMenuBlock(id: BlockID.logout.rawValue, title: NSLocalizedString("Logout", comment: ""))

        block.titleColor = UIColor(red: 200 / 255.0, green: 40 / 255.0, blue: 80 / 255.0, alpha: 1)
        block.onTouch = {
            [weak self] in
            self?.logout()
        }

        return block
    }

    private func logout() {
        AuthInfo.shared.token = nil
        view?.presentAuth()
    }
}
