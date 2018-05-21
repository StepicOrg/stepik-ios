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
            //self?.presenter?.updateProfile()
        }), for: .connectionError)

        registerPlaceholder(placeholder: StepikPlaceholder(.emptyProfileLoading), for: .refreshing)

        presenter = ProfilePresenter(userId: AuthInfo.shared.userId, view: self, userActivitiesAPI: ApiDataDownloader.userActivities, usersAPI: ApiDataDownloader.users, notificationPermissionManager: NotificationPermissionManager())
        presenter?.refresh()

        shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(ProfileViewController.shareButtonPressed))
        self.navigationItem.rightBarButtonItem = shareBarButtonItem!

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }

        self.title = NSLocalizedString("Profile", comment: "")

        setEmpty()
    }

    @objc func shareButtonPressed() {
        //presenter?.sharePressed()
    }

    func getHeader() -> ProfileInfoView? {
        profileStreaksView = ProfileHeaderInfoView.fromNib()
        guard let profileStreaksView = profileStreaksView else {
            return nil
        }
        return profileStreaksView
    }

    var profileStreaksView: ProfileHeaderInfoView?

    func refreshProfileStreaksView() {
        guard let view = profileStreaksView else {
            return
        }

        view.frame.size = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }

    func setEmpty() {
        self.tableView.tableHeaderView = nil
        self.menu = Menu(blocks: [])
    }

    // MARK: - ProfileView

    func set(state: ProfileState) {
        //self.state = state
        switch state {
        case .authorized:
            refreshProfileStreaksView()
            tableView.tableHeaderView = profileStreaksView
            tableView.layoutIfNeeded()
            break
        default:
            setEmpty()
            break
        }
    }

    // MARK: - Menu initialization

    let notificationsSwitchBlockId = "notifications_switch"
    private let notificationsTimeSelectionBlockId = "notifications_time_selection"
    private let infoBlockId = "info"
    private let pinsMapBlockId = "pins_map"
    private let settingsBlockId = "settings"
    private let downloadsBlockId = "downloads"
    private let logoutBlockId = "logout"

    private func buildMenu(user: User, userActivity: UserActivity) -> Menu {
        var blocks: [MenuBlock] = []
//        blocks = (AuthInfo.shared.userId == user.id ?
//            [
//            buildNotificationsSwitchBlock(),
//            buildNotificationsTimeSelectionBlock(),
//            buildPinsMapExpandableBlock(activity: userActivity),
//            buildInfoExpandableBlock(user: user),
//            buildSettingsTransitionBlock(),
//            buildDownloadsTransitionBlock(),
//            buildLogoutBlock()
//            ] :
//            [
//            buildInfoExpandableBlock(user: user),
//            buildPinsMapExpandableBlock(activity: userActivity)
//            ]).flatMap { $0 }
        return Menu(blocks: blocks)
    }

//    private func buildNotificationsSwitchBlock() -> SwitchMenuBlock {
//        let block: SwitchMenuBlock = SwitchMenuBlock(id: notificationsSwitchBlockId, title: NSLocalizedString("NotifyAboutStreaksPreference", comment: ""), isOn: self.hasPermissionToSendStreakNotifications)
//
////        block.hasSeparatorOnBottom = !self.hasPermissionToSendStreakNotifications
//
//        block.onSwitch = {
//            [weak self]
//            isOn in
//            self?.setStreakNotifications(on: isOn, forBlock: block)
//
////            block.hasSeparatorOnBottom = !isOn
//        }
//
//        return block
//    }
//
//    private var currentZone00UTC: String {
//        let date = Date(timeIntervalSince1970: 0)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .none
//        dateFormatter.timeStyle = .short
//        dateFormatter.timeZone = TimeZone.current
//        return dateFormatter.string(from: date)
//    }
//
//    private func buildNotificationsTimeSelectionBlock() -> TransitionMenuBlock? {
//        guard let notificationTimeString = notificationTimeString else {
//            return nil
//        }
//
//        let notificationTimeSubtitle = "\(NSLocalizedString("StreaksAreUpdated", comment: "")) \(currentZone00UTC)\n\(TimeZone.current.localizedName(for: .standard, locale: .current) ?? "")"
//
//        let block: TransitionMenuBlock = TransitionMenuBlock(id: notificationsTimeSelectionBlockId, title: "\(NSLocalizedString("NotificationTime", comment: "")): \(notificationTimeString)")
//
//        block.subtitle = notificationTimeSubtitle
//
//        block.onTouch = {
//            [weak self] in
//            self?.presentStreakTimeSelection(forBlock: block)
//            self?.menu.update(block: block)
//        }
//
//        block.onAppearance = {
//            [weak self] in
//            guard AuthInfo.shared.isAuthorized else {
//                return
//            }
//            if let newTitle = self?.notificationTimeString {
//                if block.title != "\(NSLocalizedString("NotificationTime", comment: "")): \(newTitle)" {
//                    block.title = "\(NSLocalizedString("NotificationTime", comment: "")): \(newTitle)"
//                    self?.menu.update(block: block)
//                }
//            }
//        }
//
//        return block
//    }
//
//    private func buildInfoExpandableBlock(user: User) -> TitleContentExpandableMenuBlock? {
//        var content: [TitleContentExpandableMenuBlock.TitleContent] = []
//        if user.bio.count > 0 {
//            content += [(title: NSLocalizedString("ShortBio", comment: ""), content: user.bio)]
//        }
//        if user.details.count > 0 {
//            content += [(title: NSLocalizedString("Info", comment: ""), content: user.details)]
//        }
//
//        guard content.count > 0 else {
//            return nil
//        }
//
//        let block: TitleContentExpandableMenuBlock = TitleContentExpandableMenuBlock(id: infoBlockId, title: "\(NSLocalizedString("ShortBio", comment: "")) & \(NSLocalizedString("Info", comment: ""))")
//
//        block.content = content
//
//        block.onExpanded = { isExpanded in
//            block.isExpanded = isExpanded
//        }
//        return block
//    }
//
//    private func buildPinsMapExpandableBlock(activity: UserActivity) -> PinsMapExpandableMenuBlock? {
//        let block = PinsMapExpandableMenuBlock(id: pinsMapBlockId, title: NSLocalizedString("Activity", comment: ""))
//
//        block.pins = activity.pins
//
//        block.onExpanded = { isExpanded in
//            block.isExpanded = isExpanded
//        }
//        return block
//    }
//
//    private func buildSettingsTransitionBlock() -> TransitionMenuBlock {
//        let block: TransitionMenuBlock = TransitionMenuBlock(id: settingsBlockId, title: NSLocalizedString("Settings", comment: ""))
//
//        block.onTouch = {
//            [weak self] in
//            AnalyticsReporter.reportEvent(AnalyticsEvents.Profile.clickSettings)
//            self?.view?.navigateToSettings()
//        }
//
//        return block
//    }
//
//    private func buildDownloadsTransitionBlock() -> TransitionMenuBlock {
//        let block: TransitionMenuBlock = TransitionMenuBlock(id: downloadsBlockId, title: NSLocalizedString("Downloads", comment: ""))
//
//        block.onTouch = {
//            [weak self] in
//            self?.view?.navigateToDownloads()
//        }
//
//        return block
//    }
//
//    private func buildLogoutBlock() -> TransitionMenuBlock {
//        let block: TransitionMenuBlock = TransitionMenuBlock(id: logoutBlockId, title: NSLocalizedString("Logout", comment: ""))
//
//        block.titleColor = UIColor(red: 200 / 255.0, green: 40 / 255.0, blue: 80 / 255.0, alpha: 1)
//        block.onTouch = {
//            [weak self] in
//            self?.logout()
//        }
//
//        return block
//    }
//
    var streaksTooltip: Tooltip?

    func set(menu: Menu) {
//        self.menu = menu
//
//        guard let presenter = presenter else {
//            return
//        }
//
//        guard let blockIndex = menu.getBlockIndex(id: presenter.notificationsSwitchBlockId),
//            let block = menu.getBlock(id: presenter.notificationsSwitchBlockId) as? SwitchMenuBlock else {
//            return
//        }
//
//        if TooltipDefaultsManager.shared.shouldShowOnStreaksSwitchInProfile {
//            delay(0.1) {
//                [weak self] in
//                guard let s = self else {
//                    return
//                }
//                if let cell = s.tableView.cellForRow(at: IndexPath(row: blockIndex, section: 0)) as? SwitchMenuBlockTableViewCell {
//                    if !cell.blockSwitch.isOn {
//                        let oldOnSwitch = block.onSwitch
//                        block.onSwitch = {
//                            [weak self]
//                            isOn in
//                            self?.streaksTooltip?.dismiss()
//                            oldOnSwitch?(isOn)
//                        }
//                        s.streaksTooltip = TooltipFactory.streaksTooltip
//                        s.streaksTooltip?.show(direction: .up, in: s.tableView, from: cell.blockSwitch)
//                        TooltipDefaultsManager.shared.didShowOnStreaksSwitchInProfile = true
//                    }
//                }
//            }
//        }
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
        refreshProfileStreaksView()
        tableView.tableHeaderView = profileStreaksView
        tableView.layoutIfNeeded()

        //self.presenter?.updateProfile()
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

enum ProfileState {
    case authorized
    case refreshing
    case error
    case anonymous
}
