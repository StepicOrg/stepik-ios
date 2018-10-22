//
//  ProfileViewController+StreakNotificationsControlView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.05.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//
import UIKit
import Presentr

extension ProfileViewController: StreakNotificationsControlView {
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
}
