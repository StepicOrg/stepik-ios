//
//  ProfileViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.10.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class ProfileViewController: UITableViewController {

    @IBOutlet weak var signInHeight: NSLayoutConstraint!
    @IBOutlet weak var signInNameDistance: NSLayoutConstraint!

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var signOutButton: UIButton!

    @IBOutlet weak var streaksView: StreaksView!

    var heightForRows = [[131], [0], [40]]
    let selectionForRows = [[false], [false], [true]]
    let sectionTitles = [
        NSLocalizedString("UserInfo", comment: ""),
        NSLocalizedString("Activity", comment: ""),
        NSLocalizedString("Actions", comment: "")
    ]

    fileprivate func localize() {
        signInButton.setTitle(NSLocalizedString("SignIn", comment: ""), for: UIControlState())
        signOutButton.setTitle(NSLocalizedString("SignOut", comment: ""), for: UIControlState())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)

        localize()
        signInButton.setStepicWhiteStyle()
        signInButton.isHidden = false
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        // Do any additional setup after loading the view.
    }

    func setStreaks(activity: UserActivity) {
        streaksView.setStreaks(current: activity.currentStreak, best: activity.longestStreak)
    }

    func updateUser() {
        if let user = AuthInfo.shared.user {
            self.initWithUser(user)
        } else {
            performRequest({
                if let user = AuthInfo.shared.user {
                    self.initWithUser(user)
                }
            }, error: {
                [weak self]
                error in
                guard let s = self else { return }
                if error == PerformRequestError.noAccessToRefreshToken {
                    AuthInfo.shared.token = nil
                    RoutingManager.auth.routeFrom(controller: s, success: {
                        [weak self] in
                        self?.updateUser()
                    }, cancel: {
                        [weak self] in
                        self?.updateUser()
                    })
                }
            })
        }
    }

    fileprivate func initWithUser(_ user: User) {
        print("\(user.avatarURL)")

        if !AuthInfo.shared.isAuthorized {
            signInHeight.constant = 40
            signInNameDistance.constant = 8
            heightForRows[0][0] = 131 + 48
            heightForRows[2][0] = 0
            heightForRows[1][0] = 0
            signInButton.isHidden = false
            userNameLabel.text = NSLocalizedString("NotWithUsYet", comment: "")
            avatarImageView.contentMode = UIViewContentMode.scaleAspectFit
            avatarImageView.image = Images.placeholders.anonymous
        } else {
            signInHeight.constant = 0
            signInNameDistance.constant = 0
            heightForRows[0][0] = 131
            heightForRows[2][0] = 40
//            heightForRows[1][0] = 0
            signInButton.isHidden = true
            avatarImageView.contentMode = UIViewContentMode.scaleAspectFill

            if let url = URL(string: user.avatarURL) {
                avatarImageView.set(with: url)
            }
            userNameLabel.text = "\(user.firstName) \(user.lastName)"
        }

        if AuthInfo.shared.isAuthorized {
            _ = ApiDataDownloader.userActivities.retrieve(user: user.id, success: {
                [weak self]
                activity in
                if let s = self {
                    s.setStreaks(activity: activity)
                    s.heightForRows[1][0] = 108
                    s.tableView.beginUpdates()
                    s.tableView.endUpdates()
                }
            }, error: {
                _ in

                //TODO: Display error button
            })
        }

        print("beginning updates")
        tableView.reloadData()
    }

    func dayLocalizableFor(daysCnt: Int) -> String {
        switch (daysCnt % 10) {
        case 1: return NSLocalizedString("days1", comment: "")
        case 2, 3, 4: return NSLocalizedString("days234", comment: "")
        default: return NSLocalizedString("days567890", comment: "")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        if !AuthInfo.shared.isAuthorized {
            tableView.reloadData()
        }
        updateUser()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        if (section == 2 && heightForRows[2][0] == 0) || (section == 1 && heightForRows[1][0] == 0) {
            return nil
        } else {
            return sectionTitles[section]
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if !AuthInfo.shared.isAuthorized {
            return 0
        } else {
            return sectionTitles.count
        }
    }

    func signOut() {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Logout.clicked, parameters: nil)
        AuthInfo.shared.token = nil
        let updateBlock : (() -> Void) = {
            [weak self] in
            self?.updateUser()
        }
        RoutingManager.auth.routeFrom(controller: self, success: updateBlock, cancel: updateBlock)
    }

    func signIn() {
        RoutingManager.auth.routeFrom(controller: self, success: {
            [weak self] in
            self?.updateUser()
        }, cancel: nil)
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

extension ProfileViewController : DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return Images.placeholders.anonymous
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("NotWithUsYet", comment: "")

        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0),
                          NSAttributedStringKey.foregroundColor: UIColor.darkGray]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {

        let text = NSLocalizedString("JoinCoursesSuggestionDescription", comment: "")

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center

        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0),
                          NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                          NSAttributedStringKey.paragraphStyle: paragraph]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let text = NSLocalizedString("SignIn", comment: "")

        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0),
                          NSAttributedStringKey.foregroundColor: UIColor.mainDark]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.groupTableViewBackground
    }
}

extension ProfileViewController : DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        let vc = ControllerHelper.getAuthController()
        self.present(vc, animated: true, completion: nil)
    }
}
