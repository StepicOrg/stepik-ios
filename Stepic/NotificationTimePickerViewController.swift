//
//  NotificationTimePickerViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class NotificationTimePickerViewController: PickerViewController {

    var startHour: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("SelectTimeTitle", comment: "")

        initializeData()
        initializeSelectedAction()
        picker.reloadAllComponents()
        picker.selectRow(startHour, inComponent: 0, animated: false)
    }

    func initializeData() {
        data = []
        for hour in 0..<24 {
            data += [getDisplayingStreakTimeInterval(startHour: hour)]
        }
    }

    func initializeSelectedAction() {
        selectedAction = {
            [weak self] in
            if let s = self {
                let selectedLocalStartHour = s.picker.selectedRow(inComponent: 0)
                let timeZoneDiff = NSTimeZone.system.secondsFromGMT() / 3600
                var selectedUTCStartHour = selectedLocalStartHour - timeZoneDiff

                if selectedUTCStartHour < 0 {
                    selectedUTCStartHour = 24 + selectedUTCStartHour
                }

                if selectedUTCStartHour > 23 {
                    selectedUTCStartHour = selectedUTCStartHour - 24
                }

                print("selected UTC start hour -> \(selectedUTCStartHour)")

                PreferencesContainer.notifications.streaksNotificationStartHourUTC = selectedUTCStartHour
                NotificationService.shared.scheduleStreakLocalNotification(UTCStartHour: selectedUTCStartHour)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getDisplayingStreakTimeInterval(startHour: Int) -> String {

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
