//
//  NewSettingsViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class NewSettingsViewController: MenuViewController, SettingsView {
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

    lazy var artView: ArtView = {
        let artView = ArtView(frame: CGRect.zero)
        artView.art = Images.arts.customizeLearningProcess
        artView.width = UIScreen.main.bounds.width
        artView.frame.size = artView.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: artView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height))
        artView.onTap = {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Profile.Settings.clickBanner)
        }
        return artView
    }()

    func setMenu(menu: Menu) {
        self.menu = menu
    }

    func changeVideoQuality(action: VideoQualityChoiceAction) {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "VideoQualityTableViewController", storyboardName: "Profile") as? VideoQualityTableViewController else {
            return
        }

        vc.action = action

        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        artView.width = size.width
        artView.frame.size = artView.systemLayoutSizeFitting(CGSize(width: size.width, height: artView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height))
    }
}
