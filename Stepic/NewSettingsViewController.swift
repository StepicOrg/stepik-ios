//
//  NewSettingsViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Presentr

class NewSettingsViewController: MenuViewController, SettingsView {
    var presenter: SettingsPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SettingsPresenter(view: self)
    }

    func setMenu(menu: Menu) {
        self.menu = menu
    }
    
    func changeVideoQuality(action: VideoQualityChoiceAction) {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "VideoQualityTableViewController", storyboardName: "Profile") as? VideoQualityTableViewController else {
            return
        }
        
        vc.action = action
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
