//
//  SettingsViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

final class SettingsViewController: MenuViewController {
    var presenter: SettingsPresenter?

    private lazy var artView: ArtView = {
        let artView = ArtView()
        artView.art = Images.arts.customizeLearningProcess
        artView.onTap = {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Profile.Settings.clickBanner)
        }
        return artView
    }()

    // MARK: ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Settings", comment: "")
        self.presenter = SettingsPresenter(view: self)

        self.tableView.tableHeaderView = self.artView
        self.sizeArtView()

        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmplitudeAnalyticsEvents.Settings.opened.send()
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        self.sizeArtView(size: size)
    }

    private func sizeArtView(size: CGSize = UIScreen.main.bounds.size) {
        self.artView.width = size.width
        let size = CGSize(
            width: self.artView.width,
            height: self.artView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        )
        self.artView.frame.size = self.artView.systemLayoutSizeFitting(size)
    }

    // MARK: Menu blocks managing

    private func makeMenuBlock(for id: SettingsMenuBlock) -> MenuBlock {
        let onTouch = { [weak self] in
            switch id {
            case .splitTestGroup:
                let viewController = ActiveSplitTestsListAssembly().makeModule()
                self?.navigationController?.pushViewController(viewController, animated: true)
            case .loadedVideoQuality:
                self?.changeVideoQuality(action: .downloading)
            case .onlineVideoQuality:
                self?.changeVideoQuality(action: .watching)
            case .codeEditorSettings:
                self?.pushViewController(identifier: "CodeEditorSettings", storyboardName: "Profile")
            case .contentLanguage:
                self?.pushViewController(identifier: "LanguageSettingsViewController", storyboardName: "Profile")
            case .downloads:
                self?.pushViewController(identifier: "DownloadsViewController", storyboardName: "Main")
            case .logout:
                self?.presenter?.logout()
            default:
                return
            }
        }
        let onSwitch: (Bool) -> Void = { [weak self] isOn in
            switch id {
            case .onlyWifiSwitch:
                self?.presenter?.changeVideoWifiReachability(to: !isOn)
            case .adaptiveModeSwitch:
                self?.presenter?.changeAdaptiveModeEnabled(to: isOn)
            default:
                return
            }
        }
        let factory = SettingsMenuBlockFactory(onTouch: onTouch, onSwitch: onSwitch)

        return factory.makeMenuBlock(for: id)
    }

    private func pushViewController(identifier: String, storyboardName: String) {
        let viewController = ControllerHelper.instantiateViewController(
            identifier: identifier,
            storyboardName: storyboardName
        )
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    private func changeVideoQuality(action: VideoQualityChoiceAction) {
        guard let viewController = ControllerHelper.instantiateViewController(
            identifier: "VideoQualityTableViewController",
            storyboardName: "Profile"
        ) as? VideoQualityTableViewController else {
            return
        }
        viewController.action = action
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SettingsViewController: SettingsView {
    func setMenu(ids: [SettingsMenuBlock]) {
        let blocks = ids.map { id in
            self.makeMenuBlock(for: id)
        }
        self.menu = Menu(blocks: blocks)
    }

    func presentAuth() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: false)
            RoutingManager.auth.routeFrom(controller: navigationController, success: nil, cancel: nil)
        }
    }
}
