//
//  PreferencesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.10.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import Presentr

class PreferencesViewController: UITableViewController {

    @IBOutlet weak var onlyWiFiSwitch: UISwitch!

    @IBOutlet weak var downloadingVideoQualityLabel: UILabel!
    @IBOutlet weak var downloadingVideoQualityTextLabel: UILabel!

    @IBOutlet weak var watchingVideoQualityLabel: UILabel!
    @IBOutlet weak var watchingVideoQualityTextLabel: UILabel!

    @IBOutlet weak var wifiLoadLabel: UILabel!

    @IBOutlet weak var autoCheckForUpdatesLabel: UILabel!
    @IBOutlet weak var checkForUpdatesButton: UIButton!
    @IBOutlet weak var autoCheckForUpdatesSwitch: UISwitch!

    @IBOutlet weak var ignoreMuteSwitchLabel: UILabel!
    @IBOutlet weak var ignoreMuteSwitchSwitch: UISwitch!

    @IBOutlet weak var notifyStreaksLabel: UILabel!
    @IBOutlet weak var notificationTimeTitleLabel: UILabel!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var allowStreaksNotificationsSwitch: UISwitch!

    var heightForRows = [[40, 0, 40, 40], [40, 40], [40, 0]]
    let selectionForRows = [[false, false, true, true], [false, true], [false, true]]
    let sectionTitles = [
        NSLocalizedString("Video", comment: ""),
        NSLocalizedString("Updates", comment: ""),
        NSLocalizedString("Notifications", comment: "")
    ]

    fileprivate func localize() {
        ignoreMuteSwitchLabel.text = NSLocalizedString("IgnoreMuteSwitch", comment: "")
        autoCheckForUpdatesLabel.text = NSLocalizedString("AutoCheckForUpdates", comment: "")
        checkForUpdatesButton.setTitle(NSLocalizedString("CheckForUpdates", comment: ""), for: UIControlState())
        wifiLoadLabel.text = NSLocalizedString("WiFiLoadPreference", comment: "")
        downloadingVideoQualityTextLabel.text = NSLocalizedString("LoadingVideoQualityPreference", comment: "")
        watchingVideoQualityTextLabel.text = NSLocalizedString("WatchingVideoQualityPreference", comment: "")
        notifyStreaksLabel.text = NSLocalizedString("NotifyAboutStreaksPreference", comment: "")
        notificationTimeTitleLabel.text = NSLocalizedString("NotificationTime", comment: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)

        if !StepicApplicationsInfo.inAppUpdatesAvailable {
            heightForRows[1] = [0, 0]
        }

        initStreaksRows()

        localize()

        onlyWiFiSwitch.isOn = !ConnectionHelper.shared.reachableOnWWAN
        ignoreMuteSwitchSwitch.isOn = AudioManager.sharedManager.ignoreMuteSwitch
        autoCheckForUpdatesSwitch.isOn = UpdatePreferencesContainer.sharedContainer.allowsUpdateChecks
        // Do any additional setup after loading the view.
    }

    fileprivate func initStreaksRows() {
        if AuthInfo.shared.isAuthorized {
            if PreferencesContainer.notifications.allowStreaksNotifications {
                allowStreaksNotificationsSwitch.isOn = true
                notificationTimeLabel.text = getDisplayingStreakTimeInterval(startHour: PreferencesContainer.notifications.streaksNotificationStartHourUTC)
                heightForRows[2][0] = 40
                heightForRows[2][1] = 40
            } else {
                heightForRows[2][0] = 40
                allowStreaksNotificationsSwitch.isOn = false
            }
        } else {
            heightForRows[2][0] = 0
            heightForRows[2][1] = 0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadingVideoQualityLabel.text = "\(VideosInfo.downloadingVideoQuality)p"
        watchingVideoQualityLabel.text = "\(VideosInfo.watchingVideoQuality)p"
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default

        initStreaksRows()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(heightForRows[indexPath.section][indexPath.row])
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return selectionForRows[indexPath.section][indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            switch indexPath.row {
            case 2:
                performSegue(withIdentifier: "showVideoQualityChoice", sender: VideoQualityChoiceAction.downloading)
                return
            case 3:
                performSegue(withIdentifier: "showVideoQualityChoice", sender: VideoQualityChoiceAction.watching)
                return
            default:
                return
            }
        }

        if indexPath.section == 1 && indexPath.row == 1 {
            checkForUpdates()
            return
        }

        if indexPath.section == 2 && indexPath.row == 1 {
            selectStreakNotificationTime()
            return
        }

    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("getting title for header in section \(section)")
        if (!StepicApplicationsInfo.inAppUpdatesAvailable && section == 1) || (!AuthInfo.shared.isAuthorized && section == 2) {
            return nil
        } else {
            return sectionTitles[section]
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (!StepicApplicationsInfo.inAppUpdatesAvailable && section == 1) || (!AuthInfo.shared.isAuthorized && section == 2) {
            return 0.1
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }

//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if !StepicApplicationsInfo.inAppUpdatesAvailable && section == 1 {
//            return 0.1
//        } else {
//            return super.tableView(tableView, heightForFooterInSection: section)
//        }
//    }

    @IBAction func allow3GChanged(_ sender: UISwitch) {
        ConnectionHelper.shared.reachableOnWWAN = !sender.isOn
    }

    @IBAction func ignoreMuteSwitchChanged(_ sender: UISwitch) {
        AudioManager.sharedManager.ignoreMuteSwitch = sender.isOn
    }

    @IBAction func allowAutoUpdateChanged(_ sender: UISwitch) {
        UpdatePreferencesContainer.sharedContainer.allowsUpdateChecks = sender.isOn
    }

    fileprivate func showStreaksSettingsNotificationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("StreakNotificationsAlertTitle", comment: ""), message: NSLocalizedString("StreakNotificationsAlertMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
            _ in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: {
            [weak self] in
            self?.allowStreaksNotificationsSwitch.setOn(false, animated: true)
        })
    }

    @IBAction func allowStreaksNotificationsChanged(_ sender: Any) {
        if allowStreaksNotificationsSwitch.isOn {

            guard let settings = UIApplication.shared.currentUserNotificationSettings, settings.types != .none else {
                showStreaksSettingsNotificationAlert()
                return
            }

            LocalNotificationManager.scheduleStreakLocalNotification(UTCStartHour: PreferencesContainer.notifications.streaksNotificationStartHourUTC)
            notificationTimeLabel.text = getDisplayingStreakTimeInterval(startHour: PreferencesContainer.notifications.streaksNotificationStartHourUTC)
            PreferencesContainer.notifications.allowStreaksNotifications = true
            heightForRows[2][1] = 40
            tableView.beginUpdates()
            tableView.endUpdates()
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.preferencesOn, parameters: nil)
        } else {
            LocalNotificationManager.cancelStreakLocalNotifications()
            PreferencesContainer.notifications.allowStreaksNotifications = false
            heightForRows[2][1] = 0
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.preferencesOff, parameters: nil)
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    func getDisplayingStreakTimeInterval(startHour: Int) -> String {

//        let timeZoneDiff = NSTimeZone.system.secondsFromGMT()
        let startInterval = TimeInterval((startHour % 24) * 60 * 60)// + timeZoneDiff)
        let startDate = Date(timeIntervalSinceReferenceDate: startInterval)
        let endInterval = TimeInterval((startHour + 1) % 24 * 60 * 60) //+ timeZoneDiff) 
        let endDate = Date(timeIntervalSinceReferenceDate: endInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
    }

    let streakTimePickerPresenter: Presentr = {
        let streakTimePickerPresenter = Presentr(presentationType: .bottomHalf)
        return streakTimePickerPresenter
    }()

    func selectStreakNotificationTime() {
        let vc = NotificationTimePickerViewController(nibName: "PickerViewController", bundle: nil) as NotificationTimePickerViewController
        vc.startHour = (PreferencesContainer.notifications.streaksNotificationStartHourUTC + NSTimeZone.system.secondsFromGMT() / 60 / 60 ) % 24
        vc.selectedBlock = {
            [weak self] in
            if let s = self {
                s.notificationTimeLabel.text = s.getDisplayingStreakTimeInterval(startHour: PreferencesContainer.notifications.streaksNotificationStartHourUTC)
            }
        }
        customPresentViewController(streakTimePickerPresenter, viewController: vc, animated: true, completion: nil)
    }

    func checkForUpdates() {
        RemoteVersionManager.sharedManager.checkRemoteVersionChange(needUpdateHandler: {
                [weak self]
                newVersion in
                if let version = newVersion {
                    let alert = VersionUpdateAlertConstructor.sharedConstructor.getUpdateAlertController(updateUrl: version.url, addNeverAskAction: false)
                    UIThread.performUI {
                        self?.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = VersionUpdateAlertConstructor.sharedConstructor.getNoUpdateAvailableAlertController()
                    UIThread.performUI {
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }, error: {
                error in
                print("error while checking for updates: \(error.code) \(error.localizedDescription)")
        })
    }

    @IBAction func checkForUpdatesButtonPressed(_ sender: UIButton) {
        checkForUpdates()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier ==  "showVideoQualityChoice" {
            guard let action = sender as? VideoQualityChoiceAction else {
                return
            }
            let dvc = segue.destination as? VideoQualityTableViewController
            dvc?.action = action
            return
        }

    }

}
