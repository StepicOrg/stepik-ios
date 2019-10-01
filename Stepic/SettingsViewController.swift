//
//  SettingsViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "Class to initialize settings w/o storyboards logic")
final class SettingsViewControllerLegacyAssembly: Assembly {
    func makeModule() -> UIViewController {
        guard let viewController = ControllerHelper.instantiateViewController(
            identifier: "SettingsViewController",
            storyboardName: "Profile"
        ) as? SettingsViewController else {
            fatalError("Failed to initialize SettingsViewController")
        }

        let presenter = SettingsPresenter(view: viewController)
        viewController.presenter = presenter

        return viewController
    }
}

final class SettingsViewController: MenuViewController {
    var presenter: SettingsPresenter?

    private lazy var artView: ArtView = {
        let artView = ArtView(frame: CGRect.zero)
        artView.onVKClick = {
            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Profile.Settings.socialNetworkClick,
                parameters: ["social": "vk"]
            )
            UIApplication.shared.openURL(SocialNetworks.vk)
        }
        artView.onFacebookClick = {
            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Profile.Settings.socialNetworkClick,
                parameters: ["social": "facebook"]
            )
            UIApplication.shared.openURL(SocialNetworks.facebook)
        }
        artView.onInstagramClick = {
            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Profile.Settings.socialNetworkClick,
                parameters: ["social": "instagram"]
            )
            UIApplication.shared.openURL(SocialNetworks.instagram)
        }
        return artView
    }()

    // MARK: - UIViewController life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(self.presenter != nil)

        self.title = NSLocalizedString("Settings", comment: "")

        self.edgesForExtendedLayout = []
        self.tableView.tableHeaderView = self.artView

        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmplitudeAnalyticsEvents.Settings.opened.send()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.layoutTableHeaderView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.tableView.layoutTableHeaderView()
    }

    // MARK: - Types

    private enum SocialNetworks {
        static let vk = URL(string: "https://vk.com/rustepik").require()
        static let facebook = URL(string: "https://facebook.com/stepikorg").require()
        static let instagram = URL(string: "https://instagram.com/stepik.education/").require()
    }
}

// MARK: - SettingsViewController: SettingsView -

extension SettingsViewController: SettingsView {
    func setMenu(menuIDs: [SettingsMenuBlock]) {
        let blocks = menuIDs.map { self.makeMenuBlock(for: $0) }
        self.menu = Menu(blocks: blocks)
    }

    func presentAuth() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: false)
            RoutingManager.auth.routeFrom(controller: navigationController, success: nil, cancel: nil)
        }
    }

    // MARK: - Private API -
    // MARK: MenuBlock

    private func makeMenuBlock(for menuBlockID: SettingsMenuBlock) -> MenuBlock {
        switch menuBlockID {
        case .videoHeader:
            return self.makeTitleMenuBlock(id: menuBlockID, title: NSLocalizedString("Video", comment: ""))
        case .loadingVideoQuality:
            return self.makeLoadingVideoQualityBlock()
        case .onlineVideoQuality:
            return self.makeOnlineVideoQualityBlock()
        case .codeEditorSettingsHeader:
            return self.makeTitleMenuBlock(
                id: menuBlockID,
                title: NSLocalizedString("CodeEditorTitle", comment: "")
            )
        case .codeEditorSettings:
            return self.makeCodeEditorSettingsBlock()
        case .appearanceHeader:
            return self.makeTitleMenuBlock(
                id: menuBlockID,
                title: NSLocalizedString("SettingsBlockTitleAppearance", comment: "")
            )
        case .stepFontSize:
            return self.makeStepFontSizeBlock()
        case .languageSettingsHeader:
            return self.makeTitleMenuBlock(
                id: menuBlockID,
                title: NSLocalizedString("LanguageSettingsTitle", comment: "")
            )
        case .contentLanguage:
            return self.makeContentLanguageSettingsBlock()
        case .adaptiveHeader:
            return self.makeTitleMenuBlock(
                id: menuBlockID,
                title: NSLocalizedString("AdaptivePreferencesTitle", comment: "")
            )
        case .adaptiveModeSwitch:
            return self.makeAdaptiveModeSwitchBlock()
        case .downloads:
            return self.makeDownloadsBlock()
        case .logout:
            return self.makeLogoutBlock()
        }
    }

    private func makeTitleMenuBlock(id: SettingsMenuBlock, title: String) -> HeaderMenuBlock {
        return HeaderMenuBlock(id: id.rawValue, title: title)
    }

    private func makeLoadingVideoQualityBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(
            id: SettingsMenuBlock.loadingVideoQuality.rawValue,
            title: NSLocalizedString("LoadingVideoQualityPreference", comment: "")
        )
        block.onTouch = { [weak self] in
            self?.displayChangeVideoQuality(action: .downloading)
        }

        return block
    }

    private func makeOnlineVideoQualityBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(
            id: SettingsMenuBlock.onlineVideoQuality.rawValue,
            title: NSLocalizedString("WatchingVideoQualityPreference", comment: "")
        )
        block.onTouch = { [weak self] in
            self?.displayChangeVideoQuality(action: .watching)
        }

        return block
    }

    private func makeStepFontSizeBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(
            id: SettingsMenuBlock.stepFontSize.rawValue,
            title: NSLocalizedString("SettingsStepFontSizeTitle", comment: "")
        )
        block.subtitle = NSLocalizedString("SettingsStepFontSizeSubtitle", comment: "")
        block.onTouch = { [weak self] in
            let assembly = SettingsStepFontSizeAssembly()
            self?.navigationController?.pushViewController(assembly.makeModule(), animated: true)
        }

        return block
    }

    private func makeCodeEditorSettingsBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(
            id: SettingsMenuBlock.codeEditorSettings.rawValue,
            title: NSLocalizedString("CodeEditorSettingsTitle", comment: "")
        )
        block.onTouch = { [weak self] in
            let assembly = CodeEditorSettingsLegacyAssembly()
            self?.navigationController?.pushViewController(assembly.makeModule(), animated: true)
        }

        return block
    }

    private func makeContentLanguageSettingsBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(
            id: SettingsMenuBlock.contentLanguage.rawValue,
            title: NSLocalizedString("ContentLanguagePreference", comment: "")
        )
        block.onTouch = { [weak self] in
            let assembly = LanguageSettingsLegacyAssembly()
            self?.navigationController?.pushViewController(assembly.makeModule(), animated: true)
        }

        return block
    }

    private func makeAdaptiveModeSwitchBlock() -> SwitchMenuBlock {
        let block = SwitchMenuBlock(
            id: SettingsMenuBlock.adaptiveModeSwitch.rawValue,
            title: NSLocalizedString("UseAdaptiveModePreference", comment: ""),
            isOn: AdaptiveStorageManager.shared.isAdaptiveModeEnabled
        )
        block.onSwitch = { [weak self] isOn in
            self?.presenter?.changeAdaptiveModeEnabled(to: isOn)
        }

        return block
    }

    private func makeDownloadsBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(
            id: SettingsMenuBlock.downloads.rawValue,
            title: NSLocalizedString("Downloads", comment: "")
        )
        block.onTouch = { [weak self] in
            self?.displayDownloads()
        }

        return block
    }

    private func makeLogoutBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(
            id: SettingsMenuBlock.logout.rawValue,
            title: NSLocalizedString("Logout", comment: "")
        )
        block.titleColor = UIColor(red: 200 / 255.0, green: 40 / 255.0, blue: 80 / 255.0, alpha: 1)
        block.onTouch = { [weak self] in
            self?.presenter?.logout()
        }

        return block
    }

    // MARK: Actions

    private func displayChangeVideoQuality(action: VideoQualityChoiceAction) {
        guard let viewController = ControllerHelper.instantiateViewController(
            identifier: "VideoQualityTableViewController",
            storyboardName: "Profile"
        ) as? VideoQualityTableViewController else {
            return
        }

        viewController.action = action

        self.navigationController?.pushViewController(viewController, animated: true)
    }

    private func displayDownloads() {
        guard let viewController = ControllerHelper.instantiateViewController(
            identifier: "DownloadsViewController",
            storyboardName: "Main"
        ) as? DownloadsViewController else {
            return
        }

        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
