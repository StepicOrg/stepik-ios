//
//  NewProfileViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 31.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Presentr

class ProfileViewController: MenuViewController, ProfileView, ControllerWithStepikPlaceholder {
    var placeholderContainer: StepikPlaceholderControllerContainer = StepikPlaceholderControllerContainer()

    var presenter: ProfilePresenter?
    var shareBarButtonItem: UIBarButtonItem?

    // User ID, if nil then we should use current user
    var userId: Int?

    var state: ProfileState = .refreshing {
        didSet {
            switch state {
            case .refreshing:
                showPlaceholder(for: .refreshing)
            case .anonymous:
                navigationItem.rightBarButtonItem = nil
                showPlaceholder(for: .anonymous)
            case .error:
                showPlaceholder(for: .connectionError)
            case .authorized:
                if let button = shareBarButtonItem {
                    navigationItem.rightBarButtonItem = button
                }
                isPlaceholderShown = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerPlaceholder(placeholder: StepikPlaceholder(.login, action: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            RoutingManager.auth.routeFrom(controller: strongSelf, success: nil, cancel: nil)
        }), for: .anonymous)

        registerPlaceholder(placeholder: StepikPlaceholder(.noConnection, action: { [weak self] in
            self?.presenter?.updateProfile()
        }), for: .connectionError)

        registerPlaceholder(placeholder: StepikPlaceholder(.emptyProfileLoading), for: .refreshing)

        state = .refreshing

        presenter = ProfilePresenter(userId: userId, view: self, userActivitiesAPI: ApiDataDownloader.userActivities, usersAPI: ApiDataDownloader.users, notificationPermissionManager: NotificationPermissionManager())
        shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(ProfileViewController.shareButtonPressed))
        self.navigationItem.rightBarButtonItem = shareBarButtonItem!

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }

        self.title = NSLocalizedString("Profile", comment: "")
    }

    @objc func shareButtonPressed() {
        presenter?.sharePressed()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var profile: ProfileData? {
        didSet {
            profileStreaksView?.profile = profile
        }
    }
    var streaks: StreakData? {
        didSet {
            profileStreaksView?.streaks = streaks
        }
    }

    var profileStreaksView: ProfileStreaksView?

    func refreshProfileStreaksView() {
        profileStreaksView = ProfileStreaksView(frame: CGRect.zero)
        guard let profileStreaksView = profileStreaksView else {
            return
        }
        profileStreaksView.profile = profile
        profileStreaksView.streaks = streaks
        profileStreaksView.frame.size = profileStreaksView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }

    func setEmpty() {
        self.tableView.tableHeaderView = nil
        self.menu = Menu(blocks: [])
        self.profile = nil
        self.streaks = nil
    }

    // MARK: - ProfileView

    func set(state: ProfileState) {
        self.state = state
        switch state {
        case .authorized:
            self.menu = presenter?.menu
            refreshProfileStreaksView()
            tableView.tableHeaderView = profileStreaksView
            break
        default:
            setEmpty()
            break
        }
    }

    func set(profile: ProfileData?) {
        self.profile = profile
    }

    func set(streaks: StreakData?) {
        self.streaks = streaks
    }

    var streaksTooltip: Tooltip?

    func set(menu: Menu) {
        self.menu = menu

        guard let presenter = presenter else {
            return
        }

        guard let blockIndex = menu.getBlockIndex(id: presenter.notificationsSwitchBlockId),
            let block = menu.getBlock(id: presenter.notificationsSwitchBlockId) as? SwitchMenuBlock else {
            return
        }

        if TooltipDefaultsManager.shared.shouldShowOnStreaksSwitchInProfile {
            delay(0.1) {
                [weak self] in
                guard let s = self else {
                    return
                }
                if let cell = s.tableView.cellForRow(at: IndexPath(row: blockIndex, section: 0)) as? SwitchMenuBlockTableViewCell {
                    if !cell.blockSwitch.isOn {
                        let oldOnSwitch = block.onSwitch
                        block.onSwitch = {
                            [weak self]
                            isOn in
                            self?.streaksTooltip?.dismiss()
                            oldOnSwitch?(isOn)
                        }
                        s.streaksTooltip = TooltipFactory.streaksTooltip
                        s.streaksTooltip?.show(direction: .up, in: s.tableView, from: cell.blockSwitch)
                        TooltipDefaultsManager.shared.didShowOnStreaksSwitchInProfile = true
                    }
                }
            }
        }
    }

    func showNotificationSettingsAlert(completion: (() -> Void)?) {
        let alert = UIAlertController(title: NSLocalizedString("StreakNotificationsAlertTitle", comment: ""), message: NSLocalizedString("StreakNotificationsAlertMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
            _ in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: {
            completion?()
        })
    }

    private let streakTimePickerPresenter: Presentr = {
        let streakTimePickerPresenter = Presentr(presentationType: .bottomHalf)
        return streakTimePickerPresenter
    }()

    func showStreakTimeSelectionAlert(startHour: Int, selectedBlock: (() -> Void)?) {
        let vc = NotificationTimePickerViewController(nibName: "PickerViewController", bundle: nil) as NotificationTimePickerViewController
        vc.startHour = startHour
        vc.selectedBlock = {
            selectedBlock?()
        }
        customPresentViewController(streakTimePickerPresenter, viewController: vc, animated: true, completion: nil)
    }

    func showShareProfileAlert(url: URL) {
        DispatchQueue.global(qos: .background).async {
            [weak self] in
            let shareVC = SharingHelper.getSharingController(url.absoluteString)
            shareVC.popoverPresentationController?.barButtonItem = self?.shareBarButtonItem
            DispatchQueue.main.async {
                [weak self] in
                self?.present(shareVC, animated: true, completion: nil)
            }
        }
    }

    func logout(onBack: (() -> Void)?) {
        AuthInfo.shared.token = nil
        RoutingManager.auth.routeFrom(controller: self, success: nil, cancel: nil)
    }

    func navigateToSettings() {
        self.performSegue(withIdentifier: "showSettings", sender: nil)
    }

    func navigateToDownloads() {
        let vc = ControllerHelper.instantiateViewController(identifier: "DownloadsViewController", storyboardName: "Main")
        navigationController?.pushViewController(vc, animated: true)
    }

    func onAppear() {
        self.presenter?.updateProfile()
        (self.navigationController as? StyledNavigationViewController)?.setStatusBarStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        streaksTooltip?.dismiss()
    }
}
