//
//  PreferencesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.10.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class PreferencesViewController: UITableViewController {

    
    @IBOutlet weak var onlyWiFiSwitch: UISwitch!
    @IBOutlet weak var videoQualityLabel: UILabel!
    @IBOutlet weak var videoQualityTextLabel: UILabel!
    @IBOutlet weak var wifiLoadLabel: UILabel!
    
    @IBOutlet weak var autoCheckForUpdatesLabel: UILabel!
    @IBOutlet weak var checkForUpdatesButton: UIButton!
    @IBOutlet weak var autoCheckForUpdatesSwitch: UISwitch!
    
    @IBOutlet weak var ignoreMuteSwitchLabel: UILabel!
    @IBOutlet weak var ignoreMuteSwitchSwitch: UISwitch!
    
    var heightForRows = [[40, 0, 40], [40, 40]]
    let selectionForRows = [[false, false, true], [false, true]]
    let sectionTitles = [
        NSLocalizedString("Video", comment: ""),
        NSLocalizedString("Updates", comment: ""),
    ]
    
    
    fileprivate func localize() {
        ignoreMuteSwitchLabel.text = NSLocalizedString("IgnoreMuteSwitch", comment: "")
        autoCheckForUpdatesLabel.text = NSLocalizedString("AutoCheckForUpdates", comment: "")
        checkForUpdatesButton.setTitle(NSLocalizedString("CheckForUpdates", comment: ""), for: UIControlState())
        wifiLoadLabel.text = NSLocalizedString("WiFiLoadPreference", comment: "") 
        videoQualityTextLabel.text = NSLocalizedString("LoadingVideoQualityPreference", comment: "")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        
        if !StepicApplicationsInfo.inAppUpdatesAvailable {
            heightForRows[1] = [0, 0]
        }
        
        localize() 
        
        onlyWiFiSwitch.isOn = !ConnectionHelper.shared.reachableOnWWAN
        ignoreMuteSwitchSwitch.isOn = AudioManager.sharedManager.ignoreMuteSwitch
        autoCheckForUpdatesSwitch.isOn = UpdatePreferencesContainer.sharedContainer.allowsUpdateChecks
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoQualityLabel.text = "\(VideosInfo.videoQuality)p"
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(heightForRows[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row])
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return selectionForRows[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).section  == 1 && (indexPath as NSIndexPath).row == 1 {
            checkForUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("getting title for header in section \(section)")
        if (!StepicApplicationsInfo.inAppUpdatesAvailable && section == 1) {
            return nil 
        } else {
            return sectionTitles[section]
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !StepicApplicationsInfo.inAppUpdatesAvailable && section == 1 {
            return 0.1
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if !StepicApplicationsInfo.inAppUpdatesAvailable && section == 1 {
            return 0.1
        } else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
    
    @IBAction func allow3GChanged(_ sender: UISwitch) {
        ConnectionHelper.shared.reachableOnWWAN = !sender.isOn
    }
    
    @IBAction func ignoreMuteSwitchChanged(_ sender: UISwitch) {
        AudioManager.sharedManager.ignoreMuteSwitch = sender.isOn
    }
    
    @IBAction func allowAutoUpdateChanged(_ sender: UISwitch) {
        UpdatePreferencesContainer.sharedContainer.allowsUpdateChecks = sender.isOn
    }
    
    func checkForUpdates() {
        RemoteVersionManager.sharedManager.checkRemoteVersionChange(needUpdateHandler:
            {
                [weak self]
                newVersion in
                if let version = newVersion {
                    let alert = VersionUpdateAlertConstructor.sharedConstructor.getUpdateAlertController(updateUrl: version.url, addNeverAskAction: false)
                    UIThread.performUI{
                        self?.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = VersionUpdateAlertConstructor.sharedConstructor.getNoUpdateAvailableAlertController()
                    UIThread.performUI{
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    
}
