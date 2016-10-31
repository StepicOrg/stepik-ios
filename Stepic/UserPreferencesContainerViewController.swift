//
//  UserPreferencesContainerViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.10.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class UserPreferencesContainerViewController: RGPageViewController {

    let tabNames = ["Profile", "Preferences"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datasource = self
        delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension UserPreferencesContainerViewController : RGPageViewControllerDelegate {
    func heightForTabAtIndex(_ index: Int) -> CGFloat {
        return 44.0 
    }
    
//    // use this to set a custom width for a tab
//    func widthForTabAtIndex(_ index: Int) -> CGFloat {
//        return 44.0
//    }
}

extension UserPreferencesContainerViewController : RGPageViewControllerDataSource {
    func numberOfPagesForViewController(_ pageViewController: RGPageViewController) -> Int {
        return 2
    }
    
    func tabViewForPageAtIndex(_ pageViewController: RGPageViewController, index: Int) -> UIView {
        let l = UILabel()
        l.text = tabNames[index]
        l.textAlignment = NSTextAlignment.center
        return l
    }
    
    func viewControllerForPageAtIndex(_ pageViewController: RGPageViewController, index: Int) -> UIViewController? {
        switch index {
        case 0:
            let vc = ControllerHelper.instantiateViewController(identifier: "Profile", storyboardName: "UserPreferences")
            return vc
        case 1:
            let vc = ControllerHelper.instantiateViewController(identifier: "Preferences", storyboardName: "UserPreferences")
            return vc
        }
    } 

}
