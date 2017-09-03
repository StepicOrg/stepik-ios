//
//  NewProfileViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 31.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Presentr

class NewProfileViewController: MenuViewController, ProfileView {

    var presenter: ProfilePresenter?

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = ProfilePresenter(view: self, userActivitiesAPI: ApiDataDownloader.userActivities, usersAPI: ApiDataDownloader.users)
        // Do any additional setup after loading the view.
//        presenter?.updateProfile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var profile: ProfileData? {
        didSet {
            profileStreaksView?.profile = profile
        }
    }
    var streaks: StreakData? {
        didSet {
            profileStreaksView?.streaks = streaks
        }
    }

    var profileStreaksView: ProfileStreaksView?

    func refreshProfileStreaksView() {
        profileStreaksView = ProfileStreaksView(frame: CGRect.zero)
        guard let profileStreaksView = profileStreaksView else {
            return
        }
        profileStreaksView.profile = profile
        profileStreaksView.streaks = streaks
        profileStreaksView.frame.size = profileStreaksView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }

    func setEmpty() {
        self.tableView.tableHeaderView = nil
        self.menu = Menu(blocks: [])
        self.profile = nil
        self.streaks = nil
    }

    // MARK: - ProfileView

    func set(state: ProfileState) {
        switch state {
        case .authorized:
            self.menu = presenter?.menu
            refreshProfileStreaksView()
            tableView.tableHeaderView = profileStreaksView
            break
        default:
            setEmpty()
            break
        }
    }

    func set(profile: ProfileData?) {
        self.profile = profile
    }

    func set(streaks: StreakData?) {
        self.streaks = streaks
    }

    func set(menu: Menu) {
        self.menu = menu
    }

    func showNotificationSettingsAlert(completion: (() -> Void)?) {
        let alert = UIAlertController(title: NSLocalizedString("StreakNotificationsAlertTitle", comment: ""), message: NSLocalizedString("StreakNotificationsAlertMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
            _ in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: {
            completion?()
        })
    }

    private let streakTimePickerPresenter: Presentr = {
        let streakTimePickerPresenter = Presentr(presentationType: .bottomHalf)
        return streakTimePickerPresenter
    }()
    
    func showStreakTimeSelectionAlert(startHour: Int, selectedBlock: (() -> Void)?) {
        let vc = NotificationTimePickerViewController(nibName: "PickerViewController", bundle: nil) as NotificationTimePickerViewController
        vc.startHour = startHour
        vc.selectedBlock = {
            selectedBlock?()
        }
        customPresentViewController(streakTimePickerPresenter, viewController: vc, animated: true, completion: nil)
    }

    func showShareProfileAlert(url: URL) {
        print("Share profile")
        //TODO: Add implementation
    }

    func logout(onBack: (() -> Void)?) {
        AuthInfo.shared.token = nil
        RoutingManager.auth.routeFrom(controller: self, success: nil, cancel: nil)
    }

    func navigateToSettings() {
        print("Navigate to settings")
        //TODO: Add implementation
    }

    func navigateToDownloads() {
        print("Navigate to downloads")
        //TODO: Add implementation
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter?.updateProfile()
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
