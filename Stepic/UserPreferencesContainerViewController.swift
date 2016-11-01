//
//  UserPreferencesContainerViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.10.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class UserPreferencesContainerViewController: RGPageViewController {

    let tabNames = ["Profile", "Preferences"]
    let numberOfTabs = 2
    
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

    override var pagerOrientation: UIPageViewControllerNavigationOrientation {
        get {
            return .horizontal
        }
    }
    
    override var tabbarPosition: RGTabbarPosition {
        get {
            return .top
        }
    }
    
    override var tabbarStyle: RGTabbarStyle {
        get {
            return RGTabbarStyle.solid
        }
    }
    
    override var tabIndicatorColor: UIColor {
        get {
            return UIColor.white
        }
    }
    
    override var barTintColor: UIColor? {
        get {
            return UIColor.stepicGreenColor()
        }
    }
    
    override var tabStyle: RGTabStyle {
        get {
            return .inactiveFaded
        }
    }
    
//    override var tabbarWidth: CGFloat {
//        get {
//            return 44.0
//        }
//    }
    
    override var tabbarHeight : CGFloat {
        get {
            return 30
        }
    }
    
    override var tabMargin: CGFloat {
        get {
            return 8.0
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: {
            [weak self] 
            _ in
            self?.tabScrollView.reloadData()
        })
    }
    
}

extension UserPreferencesContainerViewController : RGPageViewControllerDelegate {
    func widthForTabAtIndex(_ index: Int) -> CGFloat {
        return (UIScreen.main.bounds.width - 16) / CGFloat(numberOfTabs)
    }
}

extension UserPreferencesContainerViewController : RGPageViewControllerDataSource {
    func numberOfPagesForViewController(_ pageViewController: RGPageViewController) -> Int {
        return numberOfTabs
    }
    
    func tabViewForPageAtIndex(_ pageViewController: RGPageViewController, index: Int) -> UIView {
        let l = UILabel()
        l.text = tabNames[index]
        l.textColor = UIColor.white
        l.sizeToFit()
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
        default:
            return nil
        }
    } 

}
