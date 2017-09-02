//
//  NewProfileViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 31.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

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

    // MARK: - ProfileView
    func set(profile: ProfileData?) {
        //TODO: Add implementation
        print("did set profile with name \(String(describing: profile?.firstName)) \(String(describing: profile?.lastName))")
    }

    func set(state: ProfileState) {
        //TODO: Add implementation
        switch state {
        case .anonymous:
            self.menu = Menu(blocks: [])
            break
        case .authorized:
            self.menu = presenter?.menu
            break
        case .error:
            self.menu = Menu(blocks: [])
            break
        case .refreshing:
            self.menu = Menu(blocks: [])
            break
        }
    }

    func set(streaks: StreakData?) {
        print("did set streaks \(String(describing: streaks?.currentStreak))")
        //TODO: Add implementation
    }

    func set(menu: Menu) {
        self.menu = menu
        //TODO: Add implementation
    }

    func showNotificationSettingsAlert(completion: (() -> Void)?) {
        print("need to show notification settings alert")
        //TODO: Add implementation
    }

    func showStreakTimeSelectionAlert(startHour: Int, selectedBlock: (() -> Void)?) {
        print("need to set showStreakTimeSelectionAlert")
        //TODO: Add implementation
    }

    func showShareProfileAlert(url: URL) {
        print("Share profile")
        //TODO: Add implementation
    }

    func logout(onBack: (() -> Void)?) {
        print("Logout pressed")
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
