//
//  ProfileViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.10.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {

    @IBOutlet weak var signInHeight: NSLayoutConstraint!
    @IBOutlet weak var signInNameDistance: NSLayoutConstraint!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBOutlet weak var currentStreakLabel: UILabel!
    @IBOutlet weak var longestStreakLabel: UILabel!
    @IBOutlet weak var streaksActivityIndicator: UIActivityIndicatorView!
    
    
    var heightForRows = [[131], [75], [40]]
    let selectionForRows = [[false], [false], [true]]
    let sectionTitles = [
        NSLocalizedString("UserInfo", comment: ""),
        NSLocalizedString("Activity", comment: ""),
        NSLocalizedString("Actions", comment: "")
    ]

    fileprivate func localize() {
        signInButton.setTitle(NSLocalizedString("SignIn", comment: ""), for: UIControlState())
        signOutButton.setTitle(NSLocalizedString("SignOut", comment: ""), for: UIControlState())
        currentStreakLabel.text = NSLocalizedString("CurrentStreak", comment: "")
        longestStreakLabel.text = NSLocalizedString("LongestStreak", comment: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0)
        
        localize() 
        setStreaks(visible: false)
        signInButton.setStepicWhiteStyle()
        avatarImageView.setRoundedBounds(width: 0)
        signInButton.isHidden = false
        // Do any additional setup after loading the view.
    }
    
    func setStreaks(visible: Bool) {
        currentStreakLabel.isHidden = !visible
        longestStreakLabel.isHidden = !visible
        streaksActivityIndicator.isHidden = visible
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
    
    fileprivate func initWithUser(_ user : User) {
        print("\(user.avatarURL)")
        avatarImageView.sd_setImage(with: URL(string: user.avatarURL), placeholderImage: Constants.placeholderImage, options: [])
        userNameLabel.text = "\(user.firstName) \(user.lastName)"
        if !AuthInfo.shared.isAuthorized {
            signInHeight.constant = 40
            signInNameDistance.constant = 8
            heightForRows[0][0] = 131 + 48
            heightForRows[2][0] = 0
            signInButton.isHidden = false
        } else {
            signInHeight.constant = 0
            signInNameDistance.constant = 0
            heightForRows[0][0] = 131
            heightForRows[2][0] = 40
            signInButton.isHidden = true
        }
        
        _ = ApiDataDownloader.userActivities.retrieve(user: user.id, success: {
            [weak self] 
            activity in
            self?.currentStreakLabel.text = "\(NSLocalizedString("CurrentStreak", comment: "")): \(activity.currentStreak)"
            self?.longestStreakLabel.text = "\(NSLocalizedString("LongestStreak", comment: "")): \(activity.longestStreak)"
            self?.setStreaks(visible: true)
        }, error: {
            error in
        })
        
        print("beginning updates")
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        updateUser()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(heightForRows[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row])
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return selectionForRows[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0 {
            signOut()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 1 && heightForRows[2][0] == 0) {
            return nil 
        } else {
            return sectionTitles[section]
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
