//
//  SettingsViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import SVProgressHUD

// MARK: SettingsViewControllerLegacyAssembly: Assembly -

@available(*, deprecated, message: "Class to initialize settings w/o storyboards logic")
final class SettingsViewControllerLegacyAssembly: Assembly {
    private let appearance: SettingsViewController.Appearance

    init(appearance: SettingsViewController.Appearance = .init()) {
        self.appearance = appearance
    }

    func makeModule() -> UIViewController {
        guard let viewController = ControllerHelper.instantiateViewController(
            identifier: "SettingsViewController",
            storyboardName: "Profile"
        ) as? SettingsViewController else {
            fatalError("Failed to initialize SettingsViewController")
        }

        viewController.appearance = self.appearance
        viewController.downloadsProvider = DownloadsProvider(
            coursesPersistenceService: CoursesPersistenceService(),
            adaptiveStorageManager: AdaptiveStorageManager.shared,
            videoFileManager: VideoStoredFileManager(fileManager: FileManager.default),
            storageUsageService: StorageUsageService(
                videoFileManager: VideoStoredFileManager(fileManager: FileManager.default)
            )
        )

        let presenter = SettingsPresenter(
            view: viewController,
            autoplayStorageManager: AutoplayStorageManager(),
            adaptiveStorageManager: AdaptiveStorageManager.shared
        )
        viewController.presenter = presenter

        return viewController
    }
}

// MARK: - SettingsViewController (Appearance) -

extension SettingsViewController {
    struct Appearance {
        let destructiveActionColor = UIColor(red: 200 / 255.0, green: 40 / 255.0, blue: 80 / 255.0, alpha: 1)
    }
}

// MARK: - SettingsViewController: MenuViewController -

final class SettingsViewController: MenuViewController {
    var appearance: Appearance!
    var presenter: SettingsPresenterProtocol?

    fileprivate var downloadsProvider: DownloadsProviderProtocol?

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
        self.tableView.contentInsetAdjustmentBehavior = .never

        self.presenter?.refresh()
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
        case .languageHeader:
            return self.makeTitleMenuBlock(
                id: menuBlockID,
                title: NSLocalizedString("LanguageSettingsTitle", comment: "")
            )
        case .contentLanguage:
            return self.makeContentLanguageSettingsBlock()
        case .learningHeader:
            return self.makeTitleMenuBlock(
                id: menuBlockID,
                title: NSLocalizedString("LearningSettingsBlockTitle", comment: "")
            )
        case .stepFontSize:
            return self.makeStepFontSizeBlock()
        case .codeEditorSettings:
            return self.makeCodeEditorSettingsBlock()
        case .autoplaySwitch:
            return self.makeAutoplaySwitchBlock()
        case .adaptiveModeSwitch:
            return self.makeAdaptiveModeSwitchBlock()
        case .downloadedContentHeader:
            return self.makeTitleMenuBlock(
                id: menuBlockID,
                title: NSLocalizedString("DownloadedContentSettingsBlockTitle", comment: "")
            )
        case .downloads:
            return self.makeDownloadsBlock()
        case .deleteAllContent:
            return self.makeDeleteAllContentBlock()
        case .otherSettingsHeader:
            return self.makeTitleMenuBlock(
                id: menuBlockID,
                title: NSLocalizedString("OtherSettingsBlockTitle", comment: "")
            )
        case .logout:
            return self.makeLogoutBlock()
        }
    }

    private func makeTitleMenuBlock(id: SettingsMenuBlock, title: String) -> HeaderMenuBlock {
        .init(id: id.rawValue, title: title)
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

    private func makeAutoplaySwitchBlock() -> SwitchMenuBlock {
        let block = SwitchMenuBlock(
            id: SettingsMenuBlock.autoplaySwitch.rawValue,
            title: NSLocalizedString("AutoplayPreferenceTitle", comment: ""),
            isOn: self.presenter?.isAutoplayModeEnabled ?? false
        )
        block.onSwitch = { [weak self] isOn in
            self?.presenter?.isAutoplayModeEnabled = isOn
        }

        return block
    }

    private func makeAdaptiveModeSwitchBlock() -> SwitchMenuBlock {
        let block = SwitchMenuBlock(
            id: SettingsMenuBlock.adaptiveModeSwitch.rawValue,
            title: NSLocalizedString("UseAdaptiveModePreference", comment: ""),
            isOn: self.presenter?.isAdaptiveModeEnabled ?? false
        )
        block.onSwitch = { [weak self] isOn in
            self?.presenter?.isAdaptiveModeEnabled = isOn
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

    private func makeDeleteAllContentBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(
            id: SettingsMenuBlock.deleteAllContent.rawValue,
            title: NSLocalizedString("DeleteAllContentPreferenceTitle", comment: "")
        )
        block.titleColor = self.appearance.destructiveActionColor
        block.onTouch = { [weak self] in
            self?.requestDeleteAllContent { granted in
                guard granted else {
                    return
                }

                DispatchQueue.main.async {
                    self?.deleteAllContent()
                }
            }
        }

        return block
    }

    private func makeLogoutBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(
            id: SettingsMenuBlock.logout.rawValue,
            title: NSLocalizedString("Logout", comment: "")
        )
        block.titleColor = self.appearance.destructiveActionColor
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
        let assembly = DownloadsAssembly()
        self.push(module: assembly.makeModule())
    }

    private func requestDeleteAllContent(completionHandler: @escaping ((Bool) -> Void)) {
        let alert = UIAlertController(
            title: NSLocalizedString("DeleteAllContentConfirmationAlertTitle", comment: ""),
            message: NSLocalizedString("DeleteAllContentConfirmationAlertMessage", comment: ""),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Delete", comment: ""),
                style: .destructive,
                handler: { _ in
                    completionHandler(true)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: { _ in
                    completionHandler(false)
                }
            )
        )

        self.present(alert, animated: true)
    }

    private func deleteAllContent() {
        guard let downloadsProvider = self.downloadsProvider else {
            return SVProgressHUD.showError(withStatus: nil)
        }

        SVProgressHUD.show()

        firstly {
            after(.seconds(1))
        }.then {
            downloadsProvider.fetchCachedCourses()
        }.then { courses in
            downloadsProvider.deleteCachedCourses(courses)
        }.done { _ in
            SVProgressHUD.showSuccess(withStatus: nil)
        }
    }
}
