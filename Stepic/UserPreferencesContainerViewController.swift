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

    let tabNames = [
        NSLocalizedString("Profile", comment: ""), 
        NSLocalizedString("Preferences", comment: "")
    ]
    let numberOfTabs = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datasource = self
        delegate = self
                
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = nil
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
            return UIColor.navigationColor
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
            return 44.0
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
    /// Delegate objects can implement this method if tabs use dynamic width or to overwrite the default width for tabs.
    ///
    /// - parameter pageViewController: the `RGPageViewController` instance.
    /// - parameter index: the index of the tab.
    ///
    /// - returns: the width for the tab at the given index.
    func pageViewController(_ pageViewController: RGPageViewController, widthForTabAt index: Int) -> CGFloat {
        return (UIScreen.main.bounds.width - 16) / CGFloat(numberOfTabs)
    }    
}

extension UserPreferencesContainerViewController : RGPageViewControllerDataSource {
    /// Asks the dataSource for a view to display as a tab item.
    ///
    /// - parameter pageViewController: the `RGPageViewController` instance.
    /// - parameter index: the index of the tab whose view is asked.
    ///
    /// - returns: a `UIView` instance that will be shown as tab at the given index.
    public func pageViewController(_ pageViewController: RGPageViewController, tabViewForPageAt index: Int) -> UIView {
        let l = UILabel()
        l.text = tabNames[index]
        l.textColor = UIColor.white
        l.sizeToFit()
        return l
    }

    /// Asks the dataSource about the number of page.
    ///
    /// - parameter pageViewController: the `RGPageViewController` instance.
    ///
    /// - returns: the total number of pages
    public func numberOfPages(for pageViewController: RGPageViewController) -> Int {
        return numberOfTabs
    }
    
    /// Asks the datasource to give a ViewController to display as a page.
    ///
    /// - parameter pageViewController: the `RGPageViewController` instance.
    /// - parameter index: the index of the content whose ViewController is asked.
    ///
    /// - returns: a `UIViewController` instance whose view will be shown as content.
    func pageViewController(_ pageViewController: RGPageViewController, viewControllerForPageAt index: Int) -> UIViewController? {
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
