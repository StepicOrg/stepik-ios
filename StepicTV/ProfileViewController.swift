//
//  ProfileViewController.swift
//  Stepic
//
//  Created by Anton Kondrashov on 28/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var currentStreakLabel: UILabel!
    @IBOutlet weak var longestStreakLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setStreaks(visible: false)
        avatarImageView.setRoundedBounds(width: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUser()
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
        
        let signInTitle = NSLocalizedString("SignIn", comment: "")
        let signOutTitle = NSLocalizedString("SignOut", comment: "")
        if !AuthInfo.shared.isAuthorized {
            signButton.setTitle(signInTitle, for: UIControlState())
        } else {
            signButton.setTitle(signOutTitle, for: UIControlState())
        }
        
        _ = ApiDataDownloader.userActivities.retrieve(user: user.id, success: {
            [weak self]
            activity in
            if let s = self {
                s.currentStreakLabel.text = "\(NSLocalizedString("CurrentStreak", comment: "")) \(activity.currentStreak) \(s.dayLocalizableFor(daysCnt: activity.currentStreak))"
                s.longestStreakLabel.text = "\(NSLocalizedString("LongestStreak", comment: "")) \(activity.longestStreak) \(s.dayLocalizableFor(daysCnt: activity.longestStreak))"
                s.setStreaks(visible: true)
            }
            }, error: {
                error in
                
                //TODO: Display error button
        })
        
        print("beginning updates")
    }
    
    func dayLocalizableFor(daysCnt: Int) -> String {
        switch (daysCnt % 10) {
        case 1: return NSLocalizedString("days1", comment: "")
        case 2, 3, 4: return NSLocalizedString("days234", comment: "")
        default: return NSLocalizedString("days567890", comment: "")
        }
    }

    
    func setStreaks(visible: Bool) {
        currentStreakLabel.isHidden = !visible
        longestStreakLabel.isHidden = !visible
    }
    
    func signOut() {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Logout.clicked, parameters: nil)
        AuthInfo.shared.token = nil
        if let vc = TVControllerHelper.getAuthController(){
            vc.success = {
                [weak self] controller in
                self?.updateUser()
                controller.removeFromParentViewController()
                print("removed")
            }
            vc.cancel = {
                [weak self] controller in
                self?.updateUser()
                controller.removeFromParentViewController()
            }
        
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func signIn() {
        if let vc = TVControllerHelper.getAuthController(){
            vc.success = {
                [weak self] controller in
                self?.updateUser()
                controller.removeFromParentViewController()
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func signButtonTap(button: UIButton){
        if AuthInfo.shared.isAuthorized {
            signOut()
        } else {
            signIn()
        }
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
