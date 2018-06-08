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

    var profileStreaksView: ProfileHeaderInfoView?
    var profileDescriptionView: ProfileDescriptionContentView?
    var pinsMapContentView: PinsMapBlockContentView?
    var profileAchievementsView: ProfileAchievementsContentView?

    // Implementation of StreakNotificationsControlView in extension
    var presenterNotifications: StreakNotificationsControlPresenter?

    var streaksTooltip: Tooltip?
    var settingsButton: UIBarButtonItem?

    var otherUserId: Int?

    private var state: ProfileState = .normal {
        didSet {
            switch state {
            case .anonymous:
                showPlaceholder(for: .anonymous)
            case .error:
                showPlaceholder(for: .connectionError)
            case .normal:
                isPlaceholderShown = false
            case .loading:
                isPlaceholderShown = false
                if oldValue != .loading {
                    profileStreaksView?.isLoading = true
                    menu = buildLoadingMenu()
                }
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
            self?.presenter?.refresh(shouldReload: true)
        }), for: .connectionError)

        settingsButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-settings-profile"), style: .plain, target: self, action: #selector(ProfileViewController.settingsButtonPressed))

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }

        self.title = NSLocalizedString("Profile", comment: "")

        profileStreaksView = ProfileHeaderInfoView.fromNib()
        tableView.tableHeaderView = profileStreaksView

        state = .loading

        initPresenter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.layoutIfNeeded()
        tableView.layoutTableHeaderView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        streaksTooltip?.dismiss()
    }

    func onAppear() {
        presenter?.refresh()
        (self.navigationController as? StyledNavigationViewController)?.setStatusBarStyle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (self.navigationController as? StyledNavigationViewController)?.changeShadowAlpha(1.0)
    }

    func set(state: ProfileState) {
        self.state = state
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
            case .pinsMap:
                menuBlocks.append(buildPinsMapExpandableBlock())
            case .achievements:
                menuBlocks.append(buildAchievementsBlock())
            default:
                break
            }
        }
        menu = Menu(blocks: menuBlocks.compactMap { $0 })
    }

    func manageSettingsTransitionControl(isHidden: Bool) {
        if isHidden {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = settingsButton!
        }
    }

    func getView(for block: ProfileMenuBlock) -> Any? {
        switch block {
        case .infoHeader:
            return self.profileStreaksView
        case .notificationsTimeSelection, .notificationsSwitch(_):
            return self
        case .description:
            return self.profileDescriptionView
        case .pinsMap:
            return self.pinsMapContentView
        case .achievements:
            return self.profileAchievementsView
        }
    }

    private func initPresenter() {
        // Init only with other/anonymous seed
        // Presenter check anonymous seed and load self profile if we have logged user
        var seed: ProfilePresenter.UserSeed = .anonymous
        if let userId = otherUserId {
            seed = .other(id: userId)
        }

        presenter = ProfilePresenter(userSeed: seed, view: self, userActivitiesAPI: UserActivitiesAPI(), usersAPI: UsersAPI(), notificationPermissionManager: NotificationPermissionManager())
        presenter?.refresh(shouldReload: true)
    }

    @objc func settingsButtonPressed() {
        // Bad route injection :(
        if let vc = ControllerHelper.instantiateViewController(identifier: "SettingsViewController", storyboardName:  "Profile") as? SettingsViewController {
            let presenter = SettingsPresenter(view: vc)
            vc.presenter = presenter
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func buildLoadingMenu() -> Menu {
        var blocks: [MenuBlock] = []
        blocks = [
            buildPlaceholderBlock(num: 1),
            buildPlaceholderBlock(num: 2),
            buildPlaceholderBlock(num: 3),
            buildPlaceholderBlock(num: 4)
        ].compactMap { $0 }
        return Menu(blocks: blocks)
    }

    private func buildPlaceholderBlock(num: Int) -> PlaceholderMenuBlock {
        let block = PlaceholderMenuBlock(id: "placeholderBlock\(num)", title: "")
        block.hasSeparatorOnBottom = false
        block.onAppearance = { [weak block] in
            // We should run this code with delay cause to prevent detached cell
            delay(0.1) {
                block?.animate()
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

                    block.isOn = true
                    self?.menu?.insert(block: timeSelectionBlock, afterBlockWithId: ProfileMenuBlock.notificationsSwitch(isOn: false).rawValue)
                    self?.presenterNotifications?.refreshStreakNotificationTime()
                } else {
                    block.isOn = false
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
        profileDescriptionView = profileDescriptionView ?? ProfileDescriptionContentView.fromNib()
        let block = ContentExpandableMenuBlock(id: ProfileMenuBlock.description.rawValue, title: "\(NSLocalizedString("ShortBio", comment: "")) & \(NSLocalizedString("Info", comment: ""))", contentView: profileDescriptionView)

        block.onExpanded = { [weak self, weak block] isExpanded in
            guard let strongBlock = block else {
                return
            }

            if isExpanded {
                strongBlock.title = "\(NSLocalizedString("ShortBio", comment: ""))"
            } else {
                strongBlock.title = "\(NSLocalizedString("ShortBio", comment: "")) & \(NSLocalizedString("Info", comment: ""))"
            }
            strongBlock.isExpanded = isExpanded
            self?.menu?.update(block: strongBlock)
        }
        return block
    }

    private func buildPinsMapExpandableBlock() -> ContentExpandableMenuBlock? {
        pinsMapContentView = pinsMapContentView ?? PinsMapBlockContentView()
        let block = ContentExpandableMenuBlock(id: ProfileMenuBlock.pinsMap.rawValue, title: NSLocalizedString("Activity", comment: ""), contentView: pinsMapContentView)
        //block.isExpanded = true

        block.onExpanded = { [weak block] isExpanded in
            block?.isExpanded = isExpanded
        }
        return block
    }

    private func buildAchievementsBlock() -> ContentMenuBlock? {
        profileAchievementsView = profileAchievementsView ?? ProfileAchievementsContentView()
        let block = ContentMenuBlock(id: ProfileMenuBlock.achievements.rawValue, title: "Achievements", contentView: profileAchievementsView)
        return block
    }
}

enum ProfileState {
    case normal
    case loading
    case error
    case anonymous
}
