//
//  ProfilePresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 27.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol ProfileView: class {
    func set(profile: ProfileData?)
    func set(state: ProfileState)
    func set(streaks: StreakData?)
    func logout(onBack:(()->Void)?)
    func set(menu: Menu)
    func showNotificationSettingsAlert(completion: ((Void)->Void)?)
    func showStreakTimeSelectionAlert(startHour: Int, selectedBlock: ((Void)->Void)?)
    
    //Navigation
    
    func navigateToSettings()
}

class ProfilePresenter {
    
    weak var view: ProfileView?
    var userActivitiesAPI: UserActivitiesAPI
    var usersAPI: UsersAPI
    var menu: Menu = Menu(blocks: [])
    
    init(view: ProfileView, userActivitiesAPI: UserActivitiesAPI, usersAPI: UsersAPI) {
        self.view = view
        self.userActivitiesAPI = userActivitiesAPI
        self.usersAPI = usersAPI
    }
    
    // MARK: - Menu initialization
    
    let notificationsSwitchBlockId = "notifications_switch"
    let notificationsTimeSelectionBlockId = "notifications_time_selection"
    let infoExpandableBlockId = "info"
    
    private func buildMenu(user: User) -> Menu {
        var blocks: [MenuBlock] = []
        blocks += [buildNotificationsSwitchBlock()]
        if let block = buildNotificationsTimeSelectionBlock() {
            blocks += [block]
        }
        blocks += [buildInfoExpandableBlock(user: user)]
        return Menu(blocks: blocks)
    }
    
    private func buildNotificationsSwitchBlock() -> SwitchMenuBlock {
        let block: SwitchMenuBlock = SwitchMenuBlock(id: notificationsSwitchBlockId, title: "Notifications about learning", isOn: self.hasPermissionToSendStreakNotifications == true)
        
        block.onSwitch = {
            [weak self]
            isOn in
            self?.setStreakNotifications(on: isOn, forBlock: block)
        }
        
        block.onAppearance = {
            [weak self] in
            block.isOn = self?.hasPermissionToSendStreakNotifications == true
            self?.menu.update(block: block)
        }
        
        return block
    }
    
    private func buildNotificationsTimeSelectionBlock() -> TransitionMenuBlock? {
        guard let notificationTimeString = notificationTimeString else {
            return nil
        }
        let notificationTimeSubtitle = "Streaks are updated at 03:00 (Moscow Standard Time)"
        
        let block: TransitionMenuBlock = TransitionMenuBlock(id: notificationsTimeSelectionBlockId, title: notificationTimeString)
        
        block.subtitle = notificationTimeSubtitle
        
        block.onTouch = {
            [weak self]
            vc in
            self?.presentStreakTimeSelection(forBlock: block)
            self?.menu.update(block: block)
        }
        
        block.onAppearance = {
            [weak self] in
            if let newTitle = self?.notificationTimeString {
                block.title = newTitle
            }
            self?.menu.update(block: block)
        }
        
        return block
    }
    
    private func buildInfoExpandableBlock(user: User) -> TitleContentExpandableMenuBlock {
        let block : TitleContentExpandableMenuBlock = TitleContentExpandableMenuBlock(id: infoExpandableBlockId, title: "Short bio & Info")
        
        block.content = [
            (title: "Short bio", content: user.bio),
            (title: "Info", content: user.details)
        ]
        block.substitutesTitle = true
        
        return block
    }
    
    // MARK: - Streaks notifications
    
    private var hasPermissionToSendStreakNotifications : Bool {
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
            LocalNotificationManager.scheduleStreakLocalNotification(UTCStartHour: PreferencesContainer.notifications.streaksNotificationStartHourUTC)
            
            guard let timeSelectionBlock = buildNotificationsTimeSelectionBlock() else {
                return
            }
            menu.insert(block: timeSelectionBlock, afterBlockWithId: notificationsSwitchBlockId)
            PreferencesContainer.notifications.allowStreaksNotifications = true
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.preferencesOn, parameters: nil)
        } else {
            LocalNotificationManager.cancelStreakLocalNotifications()
            PreferencesContainer.notifications.allowStreaksNotifications = false
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.preferencesOff, parameters: nil)
            menu.remove(id: notificationsTimeSelectionBlockId)
        }
    }
    
    private func presentStreakTimeSelection(forBlock block: TransitionMenuBlock) {
        let startHour = (PreferencesContainer.notifications.streaksNotificationStartHourUTC + NSTimeZone.system.secondsFromGMT() / 60 / 60 ) % 24
        view?.showStreakTimeSelectionAlert(startHour: startHour, selectedBlock: {
            [weak self] in
            block.title = self?.notificationTimeString ?? ""
            self?.menu.update(block: block)
        })
    }
    
    // MARK: - Update methods
    
    func updateStreaks(user: User) {
        _ = userActivitiesAPI.retrieve(user: user.id, success: {
            [weak self]
            activity in
                self?.view?.set(streaks: StreakData(userActivity: activity))
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
            if let bioBlock = s.menu.getBlock(id: s.infoExpandableBlockId) as? TitleContentExpandableMenuBlock {
                bioBlock.content = [
                    (title: "Short bio", content: user.bio),
                    (title: "Info", content: user.details)
                ]
                self?.menu.update(block: bioBlock)
            }
        }, error: {
                error in
                return
        })
    }
    
    func updateProfile() {
        if AuthInfo.shared.isAuthorized {
            if let user = AuthInfo.shared.user {
                self.view?.set(profile: ProfileData(user: user))
                self.view?.set(state: .authorized)
                self.menu = buildMenu(user: user)
                self.view?.set(menu: menu)
                self.updateUser(user: user)
            } else {
                self.view?.set(state: .refreshing)
                performRequest({
                    [weak self] in
                    if let user = AuthInfo.shared.user {
                        self?.view?.set(profile: ProfileData(user: user))
                        self?.view?.set(state: .authorized)
                        if let menu = self?.buildMenu(user: user) {
                            self?.menu = menu
                            self?.view?.set(menu: menu)
                        }
                    } else {
                        self?.view?.set(profile: nil)
                        self?.view?.set(state: .error)
                    }
                }, error: {
                    [weak self]
                    error in
                    if error == PerformRequestError.noAccessToRefreshToken {
                        self?.view?.logout(onBack: {
                            [weak self] in
                            self?.updateProfile()
                        })
                    } else {
                        self?.view?.set(profile: nil)
                        self?.view?.set(state: .error)
                    }
                })
            }
        } else {
            self.view?.set(state: .anonymous)
        }
    }
    
    //MARK: - Other actions
    
    func sharePressed(inViewController vc: UIViewController) {
        //TODO: Add implementation
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
