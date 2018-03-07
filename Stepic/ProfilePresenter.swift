//
//  ProfilePresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 27.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol ProfileView: class {
    //State setting
    func set(profile: ProfileData?)
    func set(state: ProfileState)
    func set(streaks: StreakData?)
    func set(menu: Menu)

    //Alerts
    func showNotificationSettingsAlert(completion: (() -> Void)?)
    func showStreakTimeSelectionAlert(startHour: Int, selectedBlock: (() -> Void)?)
    func showShareProfileAlert(url: URL)

    //Navigation
    func logout(onBack:(() -> Void)?)
    func navigateToSettings()
    func navigateToDownloads()
}

class ProfilePresenter {

    weak var view: ProfileView?
    private var userActivitiesAPI: UserActivitiesAPI
    private var usersAPI: UsersAPI
    var menu: Menu = Menu(blocks: [])

    init(view: ProfileView, userActivitiesAPI: UserActivitiesAPI, usersAPI: UsersAPI) {
        self.view = view
        self.userActivitiesAPI = userActivitiesAPI
        self.usersAPI = usersAPI
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
        blocks = [
            buildNotificationsSwitchBlock(),
            buildNotificationsTimeSelectionBlock(),
            buildInfoExpandableBlock(user: user),
            buildPinsMapExpandableBlock(activity: userActivity),
            buildSettingsTransitionBlock(),
            buildDownloadsTransitionBlock(),
            buildLogoutBlock()
        ].flatMap { $0 }
        return Menu(blocks: blocks)
    }

    private func buildNotificationsSwitchBlock() -> SwitchMenuBlock {
        let block: SwitchMenuBlock = SwitchMenuBlock(id: notificationsSwitchBlockId, title: NSLocalizedString("NotifyAboutStreaksPreference", comment: ""), isOn: self.hasPermissionToSendStreakNotifications)

//        block.hasSeparatorOnBottom = !self.hasPermissionToSendStreakNotifications

        block.onSwitch = {
            [weak self]
            isOn in
            self?.setStreakNotifications(on: isOn, forBlock: block)
//            block.hasSeparatorOnBottom = !isOn
        }

        return block
    }

    private var currentZone00UTC: String {
        let date = Date(timeIntervalSince1970: 0)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }

    private func buildNotificationsTimeSelectionBlock() -> TransitionMenuBlock? {
        guard let notificationTimeString = notificationTimeString else {
            return nil
        }

        let notificationTimeSubtitle = "\(NSLocalizedString("StreaksAreUpdated", comment: "")) \(currentZone00UTC)\n\(TimeZone.current.localizedName(for: .standard, locale: .current) ?? "")"

        let block: TransitionMenuBlock = TransitionMenuBlock(id: notificationsTimeSelectionBlockId, title: "\(NSLocalizedString("NotificationTime", comment: "")): \(notificationTimeString)")

        block.subtitle = notificationTimeSubtitle

        block.onTouch = {
            [weak self] in
            self?.presentStreakTimeSelection(forBlock: block)
            self?.menu.update(block: block)
        }

        block.onAppearance = {
            [weak self] in
            guard AuthInfo.shared.isAuthorized else {
                return
            }
            if let newTitle = self?.notificationTimeString {
                if block.title != "\(NSLocalizedString("NotificationTime", comment: "")): \(newTitle)" {
                    block.title = "\(NSLocalizedString("NotificationTime", comment: "")): \(newTitle)"
                    self?.menu.update(block: block)
                }
            }
        }

        return block
    }

    private func buildInfoExpandableBlock(user: User) -> TitleContentExpandableMenuBlock? {
        var content: [TitleContentExpandableMenuBlock.TitleContent] = []
        if user.bio.count > 0 {
            content += [(title: NSLocalizedString("ShortBio", comment: ""), content: user.bio)]
        }
        if user.details.count > 0 {
            content += [(title: NSLocalizedString("Info", comment: ""), content: user.details)]
        }

        guard content.count > 0 else {
            return nil
        }

        let block: TitleContentExpandableMenuBlock = TitleContentExpandableMenuBlock(id: infoBlockId, title: "\(NSLocalizedString("ShortBio", comment: "")) & \(NSLocalizedString("Info", comment: ""))")

        block.content = content

        block.onExpanded = { isExpanded in
            block.isExpanded = isExpanded
        }
        return block
    }

    private func buildPinsMapExpandableBlock(activity: UserActivity) -> PinsMapExpandableMenuBlock? {
        let block = PinsMapExpandableMenuBlock(id: pinsMapBlockId, title: "Активность")

        block.pins = activity.pins

        block.onExpanded = { isExpanded in
            block.isExpanded = isExpanded
        }
        return block
    }

    private func buildSettingsTransitionBlock() -> TransitionMenuBlock {
        let block: TransitionMenuBlock = TransitionMenuBlock(id: settingsBlockId, title: NSLocalizedString("Settings", comment: ""))

        block.onTouch = {
            [weak self] in
            AnalyticsReporter.reportEvent(AnalyticsEvents.Profile.clickSettings)
            self?.view?.navigateToSettings()
        }

        return block
    }

    private func buildDownloadsTransitionBlock() -> TransitionMenuBlock {
        let block: TransitionMenuBlock = TransitionMenuBlock(id: downloadsBlockId, title: NSLocalizedString("Downloads", comment: ""))

        block.onTouch = {
            [weak self] in
            self?.view?.navigateToDownloads()
        }

        return block
    }

    private func buildLogoutBlock() -> TransitionMenuBlock {
        let block: TransitionMenuBlock = TransitionMenuBlock(id: logoutBlockId, title: NSLocalizedString("Logout", comment: ""))

        block.titleColor = UIColor(red: 200 / 255.0, green: 40 / 255.0, blue: 80 / 255.0, alpha: 1)
        block.onTouch = {
            [weak self] in
            self?.logout()
        }

        return block
    }

    // MARK: - Streaks notifications

    private var hasPermissionToSendStreakNotifications: Bool {
        return PreferencesContainer.notifications.allowStreaksNotifications
    }

    private var notificationTimeString: String? {
        func getDisplayingStreakTimeInterval(startHour: Int) -> String {
            let startInterval = TimeInterval((startHour % 24) * 60 * 60)// + timeZoneDiff)
            let startDate = Date(timeIntervalSinceReferenceDate: startInterval)
            let endInterval = TimeInterval((startHour + 1) % 24 * 60 * 60) //+ timeZoneDiff)
            let endDate = Date(timeIntervalSinceReferenceDate: endInterval)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
        }

        if hasPermissionToSendStreakNotifications {
            return getDisplayingStreakTimeInterval(startHour: PreferencesContainer.notifications.streaksNotificationStartHourUTC)
        } else {
            return nil
        }
    }

    private func setStreakNotifications(on allowNotifications: Bool, forBlock block: SwitchMenuBlock) {
        if allowNotifications {
            guard let settings = UIApplication.shared.currentUserNotificationSettings, settings.types != .none else {
                self.view?.showNotificationSettingsAlert(completion: {
                    [weak self] in
                    block.isOn = false
                    self?.menu.update(block: block)
                })
                return
            }
            PreferencesContainer.notifications.allowStreaksNotifications = true
            guard let timeSelectionBlock = buildNotificationsTimeSelectionBlock() else {
                PreferencesContainer.notifications.allowStreaksNotifications = false
                return
            }
            LocalNotificationManager.scheduleStreakLocalNotification(UTCStartHour: PreferencesContainer.notifications.streaksNotificationStartHourUTC)
            menu.insert(block: timeSelectionBlock, afterBlockWithId: notificationsSwitchBlockId)
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.preferencesOn, parameters: nil)
        } else {
            LocalNotificationManager.cancelStreakLocalNotifications()
            PreferencesContainer.notifications.allowStreaksNotifications = false
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.preferencesOff, parameters: nil)
            menu.remove(id: notificationsTimeSelectionBlockId)
        }
        block.isOn = allowNotifications
    }

    private func presentStreakTimeSelection(forBlock block: TransitionMenuBlock) {
        let startHour = PreferencesContainer.notifications.streaksNotificationStartHourLocal
        view?.showStreakTimeSelectionAlert(startHour: startHour, selectedBlock: {
            [weak self] in
            block.title = "\(NSLocalizedString("NotificationTime", comment: "")): \(self?.notificationTimeString ?? "")"
            self?.menu.update(block: block)
        })
    }

    // MARK: - Update methods

    private func updateStreaks(user: User) {
        _ = userActivitiesAPI.retrieve(user: user.id, success: { [weak self] activity in
            self?.view?.set(streaks: StreakData(userActivity: activity))
            if let pinsBlockId = self?.pinsMapBlockId, let pinsMapBlock = self?.menu.getBlock(id: pinsBlockId) as? PinsMapExpandableMenuBlock {
                pinsMapBlock.pins = activity.pins
                self?.menu.update(block: pinsMapBlock)
            }
        }, error: {
            _ in
            self.view?.set(streaks: nil)
        })
    }

    private func updateUser(user: User) {
        usersAPI.retrieve(ids: [user.id], existing: [user], refreshMode: .update, success: {
            [weak self]
            users in
            guard let s = self, let user = users.first else {
                return
            }
            if let bioBlock = s.menu.getBlock(id: s.infoBlockId) as? TitleContentExpandableMenuBlock {
                let newContent : [TitleContentExpandableMenuBlock.TitleContent] = [
                    (title: NSLocalizedString("ShortBio", comment: ""), content: user.bio),
                    (title: NSLocalizedString("Info", comment: ""), content: user.details)
                ]

                if !newContent.elementsEqual(bioBlock.content, by: { l, r in
                    return l.title == r.title && l.content == r.content}) {
                    bioBlock.content = newContent
                    self?.menu.update(block: bioBlock)
                }
            }
        }, error: {
                _ in
                return
        })
    }

    private func setUser(user: User) {
        self.menu = buildMenu(user: user, userActivity: UserActivity(id: user.id))
        self.view?.set(menu: menu)
        self.view?.set(profile: ProfileData(user: user))
        self.view?.set(state: .authorized)
        self.updateStreaks(user: user)
    }

    private func setError() {
        self.view?.set(profile: nil)
        self.view?.set(state: .error)
    }

    func updateProfile() {
        if AuthInfo.shared.isAuthorized {
            if let user = AuthInfo.shared.user {
                self.setUser(user: user)
                self.updateUser(user: user)
            } else {
                self.view?.set(state: .refreshing)
                performRequest({
                    [weak self] in
                    if let user = AuthInfo.shared.user {
                        self?.setUser(user: user)
                    } else {
                        self?.setError()
                    }
                }, error: {
                    [weak self]
                    error in
                    if error == PerformRequestError.noAccessToRefreshToken {
                        self?.logout()
                    } else {
                        self?.setError()
                    }
                })
            }
        } else {
            self.view?.set(state: .anonymous)
        }
    }

    private func logout() {
        self.view?.logout(onBack: {
            [weak self] in
            self?.updateProfile()
        })
    }

    // MARK: - Other actions

    func sharePressed() {
        guard let user = AuthInfo.shared.user else {
            return
        }
        let urlString = StepicApplicationsInfo.stepicURL + "/users/\(user.id)"
        if let url = URL(string: urlString) {
            self.view?.showShareProfileAlert(url: url)
        }
    }
}

enum ProfileState {
    case authorized
    case refreshing
    case error
    case anonymous
}

struct ProfileData {
    var avatarURLString: String
    var firstName: String
    var lastName: String
    init(user: User) {
        self.avatarURLString = user.avatarURL
        self.firstName = user.firstName
        self.lastName = user.lastName
    }
}

struct StreakData {
    var didSolveToday: Bool
    var currentStreak: Int
    var longestStreak: Int
    init(userActivity: UserActivity) {
        self.didSolveToday = userActivity.pins[0] != 0
        self.currentStreak = userActivity.currentStreak
        self.longestStreak = userActivity.longestStreak
    }
}
