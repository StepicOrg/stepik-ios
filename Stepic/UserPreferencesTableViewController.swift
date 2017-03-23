//
//  UserPreferencesTableViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.09.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD


//WARNING: Deprecated class
class UserPreferencesTableViewController: UITableViewController {
    
    @IBOutlet weak var signInHeight: NSLayoutConstraint!
    @IBOutlet weak var signInNameDistance: NSLayoutConstraint!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var onlyWiFiSwitch: UISwitch!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var videoQualityLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var autoCheckForUpdatesLabel: UILabel!
    @IBOutlet weak var checkForUpdatesButton: UIButton!
    
    @IBOutlet weak var autoCheckForUpdatesSwitch: UISwitch!
    @IBOutlet weak var ignoreMuteSwitchLabel: UILabel!
    @IBOutlet weak var ignoreMuteSwitchSwitch: UISwitch!
    
    
    var heightForRows = [[131], [40, 0, 40], [40, 40], [40]]
    let selectionForRows = [[false], [false, false, true], [false, true], [true]]
    let sectionTitles = [
        NSLocalizedString("UserInfo", comment: ""),
        NSLocalizedString("Video", comment: ""),
        NSLocalizedString("Updates", comment: ""),
        NSLocalizedString("Actions", comment: "")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !StepicApplicationsInfo.inAppUpdatesAvailable {
            heightForRows[2] = [0, 0]
        }
        
        localize() 
        
        signInButton.setStepicWhiteStyle()
        
        avatarImageView.setRoundedBounds(width: 0)
        
//        if let apiUser = AuthInfo.shared.user {
//            initWithUser(apiUser)
//        } else {
//            avatarImageView.image = Constants.placeholderImage
//        }
        
        signInButton.isHidden = false
        onlyWiFiSwitch.isOn = !ConnectionHelper.shared.reachableOnWWAN
        ignoreMuteSwitchSwitch.isOn = AudioManager.sharedManager.ignoreMuteSwitch
        autoCheckForUpdatesSwitch.isOn = UpdatePreferencesContainer.sharedContainer.allowsUpdateChecks
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func updateUser() {
        if let user = AuthInfo.shared.user {
            self.initWithUser(user)
        } else {
            performRequest({
                if let user = AuthInfo.shared.user {
                    self.initWithUser(user)
                }
            })
        }
    }
    
    fileprivate func localize() {
        ignoreMuteSwitchLabel.text = NSLocalizedString("IgnoreMuteSwitch", comment: "")
        
        autoCheckForUpdatesLabel.text = NSLocalizedString("AutoCheckForUpdates", comment: "")
        checkForUpdatesButton.setTitle(NSLocalizedString("CheckForUpdates", comment: ""), for: UIControlState())
        signInButton.setTitle(NSLocalizedString("SignIn", comment: ""), for: UIControlState())
    }
    
    fileprivate func initWithUser(_ user : User) {
        avatarImageView.sd_setImage(with: URL(string: user.avatarURL), placeholderImage: Constants.placeholderImage)
        userNameLabel.text = "\(user.firstName) \(user.lastName)"
        if !AuthInfo.shared.isAuthorized {
            signInHeight.constant = 40
            signInNameDistance.constant = 8
            heightForRows[0][0] = 131 + 48
            heightForRows[3][0] = 0
            signInButton.isHidden = false
        } else {
            signInHeight.constant = 0
            signInNameDistance.constant = 0
            heightForRows[0][0] = 131
            heightForRows[3][0] = 40
            signInButton.isHidden = true
        }
        print("beginning updates")
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoQualityLabel.text = "\(VideosInfo.videoQuality)p"
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        updateUser()
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
        if (indexPath as NSIndexPath).section == 3 && (indexPath as NSIndexPath).row == 0 {
            signOut()
        }
        if (indexPath as NSIndexPath).section  == 2 && (indexPath as NSIndexPath).row == 1 {
            checkForUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("getting title for header in section \(section)")
        if (!StepicApplicationsInfo.inAppUpdatesAvailable && section == 2) || (section == 3 && heightForRows[3][0] == 0) {
            return nil 
        } else {
            return sectionTitles[section]
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !StepicApplicationsInfo.inAppUpdatesAvailable && section == 2 {
            return 0.1
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if !StepicApplicationsInfo.inAppUpdatesAvailable && section == 2 {
            return 0.1
        } else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
    
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func printTokenButtonPressed(_ sender: UIButton) {
        print(AuthInfo.shared.token?.accessToken)
    }
    
    @IBAction func printDocumentsPathButtonPressed(_ sender: UIButton) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print(documentsPath)
    }
    
    
    @IBAction func clearCacheButtonPressed(_ sender: UIButton) {
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
    
    func signOut() {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Logout.clicked, parameters: nil)
        AuthInfo.shared.token = nil
        if let vc = ControllerHelper.getAuthController() as? AuthNavigationViewController {
            vc.success = {
                [weak self] in
                self?.updateUser()
            }
            vc.cancel = vc.success
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func signIn() {
        if let vc = ControllerHelper.getAuthController() as? AuthNavigationViewController {
            vc.success = {
                [weak self] in
                self?.updateUser()
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func signInButtonPressed(_ sender: AnyObject) {
        signIn()
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        signOut()
    }
}
