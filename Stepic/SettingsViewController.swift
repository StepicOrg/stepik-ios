//
//  SettingsViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class SettingsViewController: MenuViewController, SettingsView {
    var presenter: SettingsPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SettingsPresenter(view: self)
        tableView.tableHeaderView = artView
        self.title = NSLocalizedString("Settings", comment: "")

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmplitudeAnalyticsEvents.Settings.opened.send()
    }

    lazy var artView: ArtView = {
        let artView = ArtView(frame: CGRect.zero)
        artView.art = Images.arts.customizeLearningProcess
        if #available(iOS 11.0, *) {
            artView.width = UIScreen.main.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right
        } else {
            artView.width = UIScreen.main.bounds.width
        }

        artView.frame.size = artView.systemLayoutSizeFitting(CGSize(width: artView.width, height: artView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height))
        artView.onTap = {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Profile.Settings.clickBanner)
        }
        return artView
    }()

    private func constructMenuBlock(from menuBlockID: SettingsMenuBlock) -> MenuBlock {
        switch menuBlockID {
        case .videoHeader:
            return buildTitleMenuBlock(id: menuBlockID, title: NSLocalizedString("Video", comment: ""))
        case .onlyWifiSwitch:
            return buildOnlyWifiSwitchBlock()
        case .loadedVideoQuality:
            return buildLoadedVideoQualityBlock()
        case .onlineVideoQuality:
            return buildOnlineVideoQualityBlock()
        case .codeEditorSettingsHeader:
            return buildTitleMenuBlock(id: menuBlockID, title: NSLocalizedString("CodeEditorTitle", comment: ""))
        case .codeEditorSettings:
            return buildCodeEditorSettingsBlock()
        case .languageSettingsHeader:
            return buildTitleMenuBlock(id: menuBlockID, title: NSLocalizedString("LanguageSettingsTitle", comment: ""))
        case .contentLanguage:
            return buildContentLanguageSettingsBlock()
        case .adaptiveHeader:
            return buildTitleMenuBlock(id: menuBlockID, title: NSLocalizedString("AdaptivePreferencesTitle", comment: ""))
        case .adaptiveModeSwitch:
            return buildAdaptiveModeSwitchBlock()
        case .emptyHeader:
            return buildTitleMenuBlock(id: menuBlockID, title: "")
        case .downloads:
            return buildDownloadsTransitionBlock()
        case .logout:
            return buildLogoutBlock()
        }
    }

    func setMenu(menuIDs: [SettingsMenuBlock]) {
        var blocks: [MenuBlock] = []
        for menuBlockID in menuIDs {
            blocks += [constructMenuBlock(from: menuBlockID)]
        }
        self.menu = Menu(blocks: blocks)
    }

    private func buildTitleMenuBlock(id: SettingsMenuBlock, title: String) -> HeaderMenuBlock {
        return HeaderMenuBlock(id: id.rawValue, title: title)
    }

    private func buildContentLanguageSettingsBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(id: SettingsMenuBlock.contentLanguage.rawValue, title: NSLocalizedString("ContentLanguagePreference", comment: ""))

        block.onTouch = {
            [weak self] in
            self?.changeContentLanguageSettings()
        }

        return block
    }

    private func buildLoadedVideoQualityBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(id: SettingsMenuBlock.loadedVideoQuality.rawValue, title: NSLocalizedString("LoadingVideoQualityPreference", comment: ""))

        block.onTouch = {
            [weak self] in
            self?.changeVideoQuality(action: .downloading)
        }

        return block
    }

    private func buildOnlineVideoQualityBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(id: SettingsMenuBlock.onlineVideoQuality.rawValue, title: NSLocalizedString("WatchingVideoQualityPreference", comment: ""))

        block.onTouch = {
            [weak self] in
            self?.changeVideoQuality(action: .watching)
        }

        return block
    }

    private func buildOnlyWifiSwitchBlock() -> SwitchMenuBlock {
        let block = SwitchMenuBlock(id: SettingsMenuBlock.onlyWifiSwitch.rawValue, title: NSLocalizedString("WiFiLoadPreference", comment: ""), isOn: !ConnectionHelper.shared.reachableOnWWAN)

        block.onSwitch = {
            [weak self]
            isOn in
            self?.presenter?.changeVideoWifiReachability(to: !isOn)
        }

        return block
    }

    private func buildAdaptiveModeSwitchBlock() -> SwitchMenuBlock {
        let block = SwitchMenuBlock(id: SettingsMenuBlock.adaptiveModeSwitch.rawValue, title: NSLocalizedString("UseAdaptiveModePreference", comment: ""), isOn: AdaptiveStorageManager.shared.isAdaptiveModeEnabled)

        block.onSwitch = {
            [weak self]
            isOn in
            self?.presenter?.changeAdaptiveModeEnabled(to: isOn)
        }

        return block
    }

    private func buildCodeEditorSettingsBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(id: SettingsMenuBlock.codeEditorSettings.rawValue, title: NSLocalizedString("CodeEditorSettingsTitle", comment: ""))

        block.onTouch = {
            [weak self] in
            self?.changeCodeEditorSettings()
        }

        return block
    }

    private func buildDownloadsTransitionBlock() -> TransitionMenuBlock {
        let block: TransitionMenuBlock = TransitionMenuBlock(id: SettingsMenuBlock.downloads.rawValue, title: NSLocalizedString("Downloads", comment: ""))

        block.onTouch = {
            [weak self] in
            self?.navigateToDownloads()
        }

        return block
    }

    private func buildLogoutBlock() -> TransitionMenuBlock {
        let block: TransitionMenuBlock = TransitionMenuBlock(id: SettingsMenuBlock.logout.rawValue, title: NSLocalizedString("Logout", comment: ""))

        block.titleColor = UIColor(red: 200 / 255.0, green: 40 / 255.0, blue: 80 / 255.0, alpha: 1)
        block.onTouch = {
            [weak self] in
            self?.presenter?.logout()
        }

        return block
    }

    func changeVideoQuality(action: VideoQualityChoiceAction) {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "VideoQualityTableViewController", storyboardName: "Profile") as? VideoQualityTableViewController else {
            return
        }

        vc.action = action

        self.navigationController?.pushViewController(vc, animated: true)
    }

    func changeContentLanguageSettings() {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "LanguageSettingsViewController", storyboardName: "Profile") as? LanguageSettingsViewController else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func changeCodeEditorSettings() {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "CodeEditorSettings", storyboardName: "Profile") as? CodeEditorSettingsViewController else {
            return
        }

        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if #available(iOS 11.0, *) {
            artView.width = size.width - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        } else {
            artView.width = size.width
        }
        artView.frame.size = artView.systemLayoutSizeFitting(CGSize(width: artView.width, height: artView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height))
    }

    func navigateToDownloads() {
        let vc = ControllerHelper.instantiateViewController(identifier: "DownloadsViewController", storyboardName: "Main")
        navigationController?.pushViewController(vc, animated: true)
    }

    func presentAuth() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: false)
            RoutingManager.auth.routeFrom(controller: navigationController, success: nil, cancel: nil)
        }
    }
}
