//
//  CurrentBestStreakViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Presentr

class CurrentBestStreakViewController: UIViewController {

    @IBOutlet weak var streaksView: StreaksView!
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var bottomTextLabel: UILabel!
    
    @IBOutlet weak var notificationsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var receiveNotificationsLabel: UILabel!
    @IBOutlet weak var receiveNotificationsSwitch: UISwitch!
    
    var activity : UserActivity?
    
    fileprivate func hideNotificationsView() {
        notificationsViewHeight.constant = 0
        receiveNotificationsSwitch.isHidden = true
    }
    
    fileprivate func localize() {
        topTextLabel.text = NSLocalizedString("CurrentBestStreakAlertTopText", comment: "")
        bottomTextLabel.text = NSLocalizedString("CurrentBestStreakAlertBottomText", comment: "")
        receiveNotificationsLabel.text = NSLocalizedString("ReceiveNotifications", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if AuthInfo.shared.isAuthorized {
            if PreferencesContainer.notifications.allowStreaksNotifications {
                hideNotificationsView()            
            } else {
                receiveNotificationsSwitch.isOn = false
                AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.ImproveAlert.notificationOffered)
            } 
        } else {
            hideNotificationsView()
        }
        
        if let activity = activity {
            streaksView.setStreaks(current: activity.currentStreak, best: activity.longestStreak)
        } else {
            streaksView.setStreaks(current: 0, best: 0)
        }
        
        localize()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func showStreaksSettingsNotificationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("StreakNotificationsAlertTitle", comment: ""), message: NSLocalizedString("StreakNotificationsAlertMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
            action in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: {
            [weak self] in
            self?.receiveNotificationsSwitch.setOn(false, animated: true)
        })
    }
    
    @IBAction func receiveNotificationsValueChanged(_ sender: UISwitch) {
        if receiveNotificationsSwitch.isOn {
            
            
            guard let settings = UIApplication.shared.currentUserNotificationSettings, settings.types != .none else {
                showStreaksSettingsNotificationAlert()
                return
            }
            
            LocalNotificationManager.scheduleStreakLocalNotification(UTCStartHour: PreferencesContainer.notifications.streaksNotificationStartHourUTC)
            selectStreakNotificationTime()
//            notificationTimeLabel.text = getDisplayingStreakTimeInterval(startHour: PreferencesContainer.notifications.streaksNotificationStartHourUTC)
            PreferencesContainer.notifications.allowStreaksNotifications = true
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.preferencesOn, parameters: nil)
        } else {
            LocalNotificationManager.cancelStreakLocalNotifications()
            PreferencesContainer.notifications.allowStreaksNotifications = false
        }

    }
    
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
    
    let streakTimePickerPresenter : Presentr = {
        let streakTimePickerPresenter = Presentr(presentationType: .bottomHalf)
        return streakTimePickerPresenter
    }()
    
    func selectStreakNotificationTime() {
        let vc = NotificationTimePickerViewController(nibName: "PickerViewController", bundle: nil) as NotificationTimePickerViewController 
        vc.startHour = (PreferencesContainer.notifications.streaksNotificationStartHourUTC + NSTimeZone.system.secondsFromGMT() / 60 / 60 ) % 24
        vc.cancelAction = {
            [weak self] in
            self?.receiveNotificationsSwitch.isOn = false
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.ImproveAlert.timeCancelled)
        }
        vc.selectedBlock = {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.ImproveAlert.timeSelected)
        }
        customPresentViewController(streakTimePickerPresenter, viewController: vc, animated: true, completion: nil)
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
