//
//  NotificationTimePickerViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

final class NotificationTimePickerViewController: PickerViewController {
    var startHour = 0

    private lazy var userAccountService: UserAccountServiceProtocol = UserAccountService()

    private lazy var profileStreakNotificationsProvider: NewProfileStreakNotificationsProviderProtocol = {
        NewProfileStreakNotificationsProvider(
            submissionsPersistenceService: SubmissionsPersistenceService(),
            userActivitiesPersistenceService: UserActivitiesPersistenceService()
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    private func setup() {
        self.titleLabel.text = NSLocalizedString("SelectTimeTitle", comment: "")

        self.data = (0..<24).map(self.makeFormattedStreakTimeInterval(startHour:))

        self.selectedAction = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            let selectedLocalStartHour = strongSelf.picker.selectedRow(inComponent: 0)
            let timeZoneDiff = NSTimeZone.system.secondsFromGMT() / 3600
            var selectedUTCStartHour = selectedLocalStartHour - timeZoneDiff

            if selectedUTCStartHour < 0 {
                selectedUTCStartHour += 24
            }

            if selectedUTCStartHour > 23 {
                selectedUTCStartHour -= 24
            }

            print("selected UTC start hour -> \(selectedUTCStartHour)")

            PreferencesContainer.notifications.streaksNotificationStartHourUTC = selectedUTCStartHour

            guard let currentUserID = strongSelf.userAccountService.currentUserID else {
                return
            }

            strongSelf.profileStreakNotificationsProvider.fetchStreakLocalNotificationType(
                userID: currentUserID
            ).done { streakType in
                NotificationsService().scheduleStreakLocalNotification(
                    utcStartHour: selectedUTCStartHour,
                    streakType: streakType
                )
            }
        }

        self.picker.reloadAllComponents()
        self.picker.selectRow(self.startHour, inComponent: 0, animated: false)
    }

    private func makeFormattedStreakTimeInterval(startHour: Int) -> String {
        let timeZoneDiff = NSTimeZone.system.secondsFromGMT()

        let startInterval = TimeInterval((startHour % 24) * 60 * 60 - timeZoneDiff)
        let startDate = Date(timeIntervalSinceReferenceDate: startInterval)

        let endInterval = TimeInterval((startHour + 1) % 24 * 60 * 60 - timeZoneDiff)
        let endDate = Date(timeIntervalSinceReferenceDate: endInterval)

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none

        return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
    }
}
