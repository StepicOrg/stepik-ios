//
//  NewProfileViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 31.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

final class ProfileViewController: MenuViewController, ProfileView, ControllerWithStepikPlaceholder {
    var placeholderContainer = StepikPlaceholderControllerContainer()
    var presenter: ProfilePresenter?

    var profileStreaksView: ProfileHeaderInfoView?
    var profileDescriptionView: ProfileDescriptionContentView?
    var pinsMapContentView: PinsMapBlockContentView?
    var profileAchievementsView: ProfileAchievementsContentView?

    // Implementation of StreakNotificationsControlView in extension
    var presenterNotifications: StreakNotificationsControlPresenter?

    var streaksTooltip: Tooltip?

    var settingsButton: UIBarButtonItem?
    var shareButton: UIBarButtonItem?
    var profileEditButton: UIBarButtonItem?

    var otherUserId: Int?

    // Attached profile to present profile edit
    private var profile: Profile?

    private var sharingURL: String?

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

        edgesForExtendedLayout = []

        registerPlaceholder(placeholder: StepikPlaceholder(.login, action: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            RoutingManager.auth.routeFrom(controller: strongSelf, success: nil, cancel: nil)
        }), for: .anonymous)

        registerPlaceholder(placeholder: StepikPlaceholder(.noConnection, action: { [weak self] in
            self?.presenter?.refresh(shouldReload: true)
        }), for: .connectionError)

        let settingsImage: UIImage? = {
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "gear")
            }
            return UIImage(named: "icon-settings-profile")
        }()
        self.settingsButton = UIBarButtonItem(
            image: settingsImage,
            style: .plain,
            target: self,
            action: #selector(self.settingsButtonClicked)
        )
        self.shareButton = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(ProfileViewController.shareButtonPressed)
        )
        self.profileEditButton = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(ProfileViewController.profileEditButtonPressed)
        )

        self.tableView.contentInsetAdjustmentBehavior = .never

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.sendAppearanceEvent()
    }

    func set(state: ProfileState) {
        self.state = state
    }

    func setMenu(blocks: [ProfileMenuBlock]) {
        var menuBlocks = [MenuBlock?]()
        for block in blocks {
            switch block {
            case .notificationsSwitch(let isOn):
                menuBlocks.append(self.buildNotificationsSwitchBlock(isOn: isOn))
            case .notificationsTimeSelection:
                menuBlocks.append(self.buildNotificationsTimeSelectionBlock())
            case .certificates:
                menuBlocks.append(self.buildCertificatesBlock())
            case .description:
                menuBlocks.append(self.buildInfoExpandableBlock())
            case .pinsMap:
                menuBlocks.append(self.buildPinsMapExpandableBlock())
            case .achievements:
                menuBlocks.append(self.buildAchievementsBlock())
            case .userID(let id):
                menuBlocks.append(self.buildUserIDBlock(userID: id))
            default:
                break
            }
        }
        self.menu = Menu(blocks: menuBlocks.compactMap { $0 })
    }

    func manageBarItemControls(isSettingsHidden: Bool, isEditProfileAvailable: Bool, shareID: Int?) {
        var rightBarButtonItems = [UIBarButtonItem]()

        if let settingsButton = self.settingsButton, !isSettingsHidden {
            rightBarButtonItems.append(settingsButton)
        }
        if let profileEditButton = self.profileEditButton, isEditProfileAvailable, !isSettingsHidden {
            rightBarButtonItems.append(profileEditButton)
        }

        if let shareButton = self.shareButton, let shareID = shareID {
            self.sharingURL = StepicApplicationsInfo.stepicURL + "/users/\(shareID)"
            if isSettingsHidden {
                self.navigationItem.rightBarButtonItem = shareButton
            } else {
                self.navigationItem.leftBarButtonItem = shareButton
            }
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.sharingURL = nil
        }

        self.navigationItem.rightBarButtonItems = rightBarButtonItems
    }

    func getView(for block: ProfileMenuBlock) -> Any? {
        switch block {
        case .infoHeader:
            return self.profileStreaksView
        case .notificationsTimeSelection, .notificationsSwitch, .certificates, .userID:
            return self
        case .description:
            return self.profileDescriptionView
        case .pinsMap:
            return self.pinsMapContentView
        case .achievements:
            return self.profileAchievementsView
        }
    }

    func showAchievementInfo(viewData: AchievementViewData, canShare: Bool) {
        let alertManager = AchievementPopupAlertManager(source: .profile)
        let vc = alertManager.construct(with: viewData, canShare: canShare)
        alertManager.present(alert: vc, inController: self)
    }

    func attachProfile(_ profile: Profile) {
        self.profile = profile
    }

    private func initPresenter() {
        // Init only with other/anonymous seed
        // Presenter check anonymous seed and load self profile if we have logged user
        var seed: ProfilePresenter.UserSeed = .anonymous
        if let userId = otherUserId {
            seed = .other(id: userId)
        }

        let dataBackUpdateService = DataBackUpdateService(
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        )
        presenter = ProfilePresenter(
            userSeed: seed,
            view: self,
            userActivitiesAPI: UserActivitiesAPI(),
            usersAPI: UsersAPI(),
            profilesAPI: ProfilesAPI(),
            dataBackUpdateService: dataBackUpdateService
        )
        presenter?.refresh(shouldReload: true)
    }

    @objc
    private func settingsButtonClicked() {
        let (modalPresentationStyle, navigationBarAppearance) = {
            () -> (UIModalPresentationStyle, StyledNavigationController.NavigationBarAppearanceState) in
            if #available(iOS 13.0, *) {
                return (
                    .automatic,
                    .init(
                        statusBarColor: .clear,
                        statusBarStyle: .lightContent
                    )
                )
            } else {
                return (.fullScreen, .init())
            }
        }()

        let assembly = NewSettingsAssembly(navigationBarAppearance: navigationBarAppearance)
        let controller = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: controller, embedInNavigation: false, modalPresentationStyle: modalPresentationStyle)
    }

    @objc
    private func profileEditButtonPressed() {
        guard let profile = self.profile else {
            return
        }

        let (modalPresentationStyle, navigationBarAppearance) = {
            () -> (UIModalPresentationStyle, StyledNavigationController.NavigationBarAppearanceState) in
            if #available(iOS 13.0, *) {
                return (
                    .automatic,
                    .init(
                        statusBarColor: .clear,
                        statusBarStyle: .lightContent
                    )
                )
            } else {
                return (.fullScreen, .init())
            }
        }()

        let assembly = ProfileEditAssembly(
            profile: profile,
            navigationBarAppearance: navigationBarAppearance
        )
        let controller = StyledNavigationController(rootViewController: assembly.makeModule())

        self.present(module: controller, embedInNavigation: false, modalPresentationStyle: modalPresentationStyle)
    }

    @objc func shareButtonPressed() {
        share(popoverSourceItem: shareButton)
    }

    func share(popoverSourceItem: UIBarButtonItem?) {
        guard let sharingURL = self.sharingURL else {
            return
        }
        let shareVC = SharingHelper.getSharingController(sharingURL)
        shareVC.popoverPresentationController?.barButtonItem = popoverSourceItem
        present(shareVC, animated: true, completion: nil)
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
        let block = SwitchMenuBlock(
            id: ProfileMenuBlock.notificationsSwitch(isOn: false).rawValue,
            title: NSLocalizedString("NotifyAboutStreaksPreference", comment: ""),
            isOn: isOn
        )

        block.onSwitch = { [weak self] isOn in
            self?.presenterNotifications?.setStreakNotifications(on: isOn) { [weak self] status in
                self?.setNotificationsSwitchIsOn(status)
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

    func buildNotificationsTimeSelectionBlock() -> TransitionMenuBlock? {
        var currentZone00UTC: String {
            let date = Date(timeIntervalSince1970: 0)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter.string(from: date)
        }

        let block = TransitionMenuBlock(id: ProfileMenuBlock.notificationsTimeSelection.rawValue, title: "")

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

    private func buildCertificatesBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(
            id: ProfileMenuBlock.certificates.rawValue,
            title: NSLocalizedString("Certificates", comment: "")
        )
        block.onTouch = { [weak self] in
            guard let strongSelf = self,
                  let userID = strongSelf.presenter?.userSeed.userId else {
                return
            }

            let assembly = CertificatesLegacyAssembly(userID: userID)
            strongSelf.push(module: assembly.makeModule())
        }

        return block
    }

    private func buildInfoExpandableBlock() -> ContentExpandableMenuBlock? {
        profileDescriptionView = profileDescriptionView ?? ProfileDescriptionContentView.fromNib()
        let block = ContentExpandableMenuBlock(
            id: ProfileMenuBlock.description.rawValue,
            title: "\(NSLocalizedString("ShortBio", comment: "")) & \(NSLocalizedString("Info", comment: ""))",
            contentView: self.profileDescriptionView
        )

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
        let block = ContentExpandableMenuBlock(
            id: ProfileMenuBlock.pinsMap.rawValue,
            title: NSLocalizedString("Activity", comment: ""),
            contentView: self.pinsMapContentView
        )

        block.onExpanded = { [weak block] isExpanded in
            block?.isExpanded = isExpanded
        }
        return block
    }

    private func buildAchievementsBlock() -> ContentMenuBlock? {
        profileAchievementsView = profileAchievementsView ?? ProfileAchievementsContentView.fromNib()
        let onButtonClick = { [weak self] in
            if let userId = self?.otherUserId ?? AuthInfo.shared.userId,
               let viewController = ControllerHelper.instantiateViewController(
                   identifier: "AchievementsListViewController",
                   storyboardName: "Profile"
               ) as? AchievementsListViewController {
                // FIXME: API injection :((
                let retriever = AchievementsRetriever(
                    userId: userId,
                    achievementsAPI: AchievementsAPI(),
                    achievementProgressesAPI: AchievementProgressesAPI()
                )
                let presenter = AchievementsListPresenter(
                    userId: userId,
                    view: viewController,
                    achievementsAPI: AchievementsAPI(),
                    achievementsRetriever: retriever
                )
                viewController.presenter = presenter
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }

        let block = ContentMenuBlock(
            id: ProfileMenuBlock.achievements.rawValue,
            title: NSLocalizedString("Achievements", comment: ""),
            contentView: profileAchievementsView,
            buttonTitle: NSLocalizedString("ShowAll", comment: ""),
            onButtonClick: onButtonClick
        )

        return block
    }

    private func buildUserIDBlock(userID: User.IdType) -> CustomMenuBlock {
        let label: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.textColor = UIColor(hex: 0x535366, alpha: 0.5)
            label.font = UIFont.systemFont(ofSize: 12)
            label.text = "User ID: \(userID)"
            return label
        }()
        let containerView = UIView()

        let block = CustomMenuBlock(
            id: ProfileMenuBlock.userID(id: userID).rawValue,
            contentView: containerView
        )
        block.hasSeparatorOnBottom = false
        block.isSelectable = true
        block.onClick = { [weak self] in
            guard let sharingURLString = self?.sharingURL else {
                return
            }

            UIPasteboard.general.string = sharingURLString
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Copied", comment: ""))
        }

        let insets = LayoutInsets(top: 24, left: 24, bottom: 24, right: 24)

        containerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(insets.left).priority(999)
            make.top.equalToSuperview().offset(insets.top).priority(999)
            make.trailing.equalToSuperview().offset(-insets.right).priority(999)
            make.bottom.equalToSuperview().offset(-insets.bottom).priority(999)
        }

        return block
    }
}

enum ProfileState {
    case normal
    case loading
    case error
    case anonymous
}
