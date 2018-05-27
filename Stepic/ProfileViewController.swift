//
//  NewProfileViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 31.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Presentr

class ProfileViewController: MenuViewController, ProfileView, StreakNotificationsControlView, ControllerWithStepikPlaceholder {
    var placeholderContainer: StepikPlaceholderControllerContainer = StepikPlaceholderControllerContainer()
    var presenter: ProfilePresenter?
    var presenterNotifications: StreakNotificationsControlPresenter?

    var shareBarButtonItem: UIBarButtonItem?
    var userId: Int?

    func set(state: ProfileState) {

    }

    func setMenu(blocks: [ProfileMenuBlock]) {
        var menuBlocks = [MenuBlock?]()
        for block in blocks {
            switch block {
            case .notificationsSwitch(let isOn):
                menuBlocks.append(buildNotificationsSwitchBlock(isOn: isOn))
            case .notificationsTimeSelection:
                menuBlocks.append(buildNotificationsTimeSelectionBlock())
            case .description:
                menuBlocks.append(buildInfoExpandableBlock())
            default:
                break
            }
        }
        menu = Menu(blocks: menuBlocks.flatMap { $0 })
    }

    func attachPresenter(_ presenter: StreakNotificationsControlPresenter) {
        self.presenterNotifications = presenter
    }

    func showStreakTimeSelection(startHour: Int) {
        // FIXME: strange picker injection. this vc logic should be in the presenter, i think
        let streakTimePickerPresentr = Presentr(presentationType: .bottomHalf)
        let vc = NotificationTimePickerViewController(nibName: "PickerViewController", bundle: nil) as NotificationTimePickerViewController
        vc.startHour = startHour
        vc.selectedBlock = { [weak self] in
            self?.presenterNotifications?.refreshStreakNotificationTime()
        }
        customPresentViewController(streakTimePickerPresentr, viewController: vc, animated: true, completion: nil)
    }

    func requestNotificationsPermissions() {
        let alert = UIAlertController(title: NSLocalizedString("StreakNotificationsAlertTitle", comment: ""), message: NSLocalizedString("StreakNotificationsAlertMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { _ in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }

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

    var profileStreaksView: ProfileHeaderInfoView?
    var profileDescriptionView: ProfileDescriptionContentView?

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

        shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(ProfileViewController.shareButtonPressed))
        self.navigationItem.rightBarButtonItem = shareBarButtonItem!

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }

        self.title = NSLocalizedString("Profile", comment: "")

        menu = buildLoadingMenu()

        profileStreaksView = ProfileHeaderInfoView.fromNib()
        tableView.tableHeaderView = profileStreaksView

        presenter = ProfilePresenter(userId: AuthInfo.shared.userId, view: self, userActivitiesAPI: ApiDataDownloader.userActivities, usersAPI: ApiDataDownloader.users, notificationPermissionManager: NotificationPermissionManager())
        presenter?.refresh()
    }

    @objc func shareButtonPressed() {
        //presenter?.sharePressed()
    }

    func getView(for block: ProfileMenuBlock) -> Any? {
        switch block {
        case .infoHeader:
            return self.profileStreaksView
        case .notificationsTimeSelection, .notificationsSwitch(_):
            return self
        case .description:
            return self.profileDescriptionView
        default:
            return nil
        }
    }

    private func buildLoadingMenu() -> Menu {
        var blocks: [MenuBlock] = []
        blocks = [
            buildPlaceholderBlock(num: 1),
            buildPlaceholderBlock(num: 2),
            buildPlaceholderBlock(num: 3)
        ].flatMap { $0 }
        return Menu(blocks: blocks)
    }

    private func buildPlaceholderBlock(num: Int) -> PlaceholderMenuBlock {
        let block = PlaceholderMenuBlock(id: "placeholderBlock\(num)", title: "")
        block.hasSeparatorOnBottom = false
        block.onAppearance = {
            // We should run this code with delay cause to prevent detached cell
            delay(0.1) {
                block.animate()
            }
        }
        return block
    }

    private func buildNotificationsSwitchBlock(isOn: Bool) -> SwitchMenuBlock {
        let block: SwitchMenuBlock = SwitchMenuBlock(id: ProfileMenuBlock.notificationsSwitch(isOn: false).rawValue, title: NSLocalizedString("NotifyAboutStreaksPreference", comment: ""), isOn: isOn)

        block.onSwitch = { [weak self] isOn in
            self?.presenterNotifications?.setStreakNotifications(on: isOn) { [weak self] status in
                if status {
                    guard let timeSelectionBlock = self?.buildNotificationsTimeSelectionBlock() else {
                        self?.presenterNotifications?.setStreakNotifications(on: !isOn)
                        return
                    }

                    self?.menu?.insert(block: timeSelectionBlock, afterBlockWithId: ProfileMenuBlock.notificationsSwitch(isOn: false).rawValue)
                    self?.presenterNotifications?.refreshStreakNotificationTime()
                } else {
                    self?.menu?.remove(id: ProfileMenuBlock.notificationsTimeSelection.rawValue)
                }
            }
        }

        // Tooltip "enable notifications for bla-bla"
        if TooltipDefaultsManager.shared.shouldShowOnStreaksSwitchInProfile {
            // We should run this code with delay cause to prevent detached cell
            delay(0.1) { [weak self] in
                guard let s = self else {
                    return
                }

                self?.streaksTooltip = TooltipFactory.streaksTooltip
                if let cell = block.cell as? SwitchMenuBlockTableViewCell {
                    if !cell.blockSwitch.isOn {
                        let oldOnSwitch = block.onSwitch
                        block.onSwitch = { [weak self] isOn in
                            self?.streaksTooltip?.dismiss()
                            oldOnSwitch?(isOn)
                        }
                        self?.streaksTooltip?.show(direction: .up, in: s.tableView, from: cell.blockSwitch)
                        TooltipDefaultsManager.shared.didShowOnStreaksSwitchInProfile = true
                    }
                }
            }
        }

        return block
    }

    func updateDisplayedStreakTime(startHour: Int) {
        func getDisplayingStreakTimeInterval(startHour: Int) -> String {
            let startInterval = TimeInterval((startHour % 24) * 60 * 60)
            let startDate = Date(timeIntervalSinceReferenceDate: startInterval)
            let endInterval = TimeInterval((startHour + 1) % 24 * 60 * 60)
            let endDate = Date(timeIntervalSinceReferenceDate: endInterval)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
        }

        if let block = menu?.getBlock(id: ProfileMenuBlock.notificationsTimeSelection.rawValue) {
            block.title = "\(NSLocalizedString("NotificationTime", comment: "")): \(getDisplayingStreakTimeInterval(startHour: startHour))"
            menu?.update(block: block)
        }
    }

    private func buildNotificationsTimeSelectionBlock() -> TransitionMenuBlock? {
        var currentZone00UTC: String {
            let date = Date(timeIntervalSince1970: 0)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter.string(from: date)
        }

        let block: TransitionMenuBlock = TransitionMenuBlock(id: ProfileMenuBlock.notificationsTimeSelection.rawValue, title: "")

        let notificationTimeSubtitle = "\(NSLocalizedString("StreaksAreUpdated", comment: "")) \(currentZone00UTC)\n\(TimeZone.current.localizedName(for: .standard, locale: .current) ?? "")"
        block.subtitle = notificationTimeSubtitle

        block.onTouch = { [weak self] in
            self?.presenterNotifications?.selectStreakNotificationTime()
        }

        block.onAppearance = { [weak self] in
            self?.presenterNotifications?.refreshStreakNotificationTime()
        }

        return block
    }

    private func buildInfoExpandableBlock() -> ContentExpandableMenuBlock? {
        profileDescriptionView = ProfileDescriptionContentView.fromNib()
        let block = ContentExpandableMenuBlock(id: ProfileMenuBlock.description.rawValue, title: "\(NSLocalizedString("ShortBio", comment: "")) & \(NSLocalizedString("Info", comment: ""))", contentView: profileDescriptionView)

        block.onExpanded = { [weak self] isExpanded in
            if !isExpanded {
                block.title = "\(NSLocalizedString("ShortBio", comment: ""))"
            } else {
                block.title = "\(NSLocalizedString("ShortBio", comment: "")) & \(NSLocalizedString("Info", comment: ""))"
            }
            self?.menu?.update(block: block)
            block.isExpanded = isExpanded
        }
        return block
    }

//    private func buildPinsMapExpandableBlock(activity: UserActivity) -> PinsMapExpandableMenuBlock? {
//        let block = PinsMapExpandableMenuBlock(id: ProfileMenuBlock.pinsMap.rawValue, title: NSLocalizedString("Activity", comment: ""))
//
//        block.pins = activity.pins
//
//        block.onExpanded = { isExpanded in
//            block.isExpanded = isExpanded
//        }
//        return block
//    }

    var streaksTooltip: Tooltip?

    func onAppear() {
        //self.presenter?.updateProfile()
        (self.navigationController as? StyledNavigationViewController)?.setStatusBarStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.layoutIfNeeded()
        tableView.layoutTableHeaderView()
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
