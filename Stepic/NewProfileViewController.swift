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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ProfileView
    func set(profile: ProfileData?) {
        //TODO: Add implementation
    }

    func set(state: ProfileState) {
        //TODO: Add implementation
    }

    func set(streaks: StreakData?) {
        //TODO: Add implementation
    }

    func set(menu: Menu) {
        //TODO: Add implementation
    }

    func showNotificationSettingsAlert(completion: (() -> Void)?) {
        //TODO: Add implementation
    }

    func showStreakTimeSelectionAlert(startHour: Int, selectedBlock: (() -> Void)?) {
        //TODO: Add implementation
    }

    func showShareProfileAlert(url: URL) {
        //TODO: Add implementation
    }

    func logout(onBack: (() -> Void)?) {
        //TODO: Add implementation
    }

    func navigateToSettings() {
        //TODO: Add implementation
    }

    func navigateToDownloads() {
        //TODO: Add implementation
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
