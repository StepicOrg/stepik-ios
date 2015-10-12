//
//  StepsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class StepsViewController: RGPageViewController {

    var lesson : Lesson?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datasource = self
        delegate = self
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        UICustomizer.sharedCustomizer.setStepicTabBar(self.tabBarController?.tabBar)
        
        lesson?.loadSteps(completion: {
            self.reloadData()
        })
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var pagerOrientation: UIPageViewControllerNavigationOrientation {
        get {
            return .Horizontal
        }
    }
    
    override var tabbarPosition: RGTabbarPosition {
        get {
            return .Top
        }
    }
    
    override var tabbarStyle: RGTabbarStyle {
        get {
            return RGTabbarStyle.Solid
        }
    }
    
    override var tabIndicatorColor: UIColor {
        get {
            return UIColor.whiteColor()
        }
    }
    
    override var barTintColor: UIColor? {
        get {
            return UIColor.stepicGreenColor()
        }
    }
    
    override var tabStyle: RGTabStyle {
        get {
            return .InactiveFaded
        }
    }
    
    override var tabbarWidth: CGFloat {
        get {
            return 44.0
        }
    }
    
    override var tabbarHeight : CGFloat {
        get {
            return 44.0
        }
    }
    
    override var tabMargin: CGFloat {
        get {
            return 16.0
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



extension StepsViewController : RGPageViewControllerDataSource {
    func numberOfPagesForViewController(pageViewController: RGPageViewController) -> Int {
        return lesson?.steps.count ?? 0
    }
    
    func tabViewForPageAtIndex(pageViewController: RGPageViewController, index: Int) -> UIView {
        let tabView = UILabel()
        
        tabView.font = UIFont.systemFontOfSize(17)
        tabView.text = lesson?.steps[index].block.name
        tabView.textColor = UIColor.whiteColor()
        tabView.sizeToFit()
        return tabView
    }
    
    func viewControllerForPageAtIndex(pageViewController: RGPageViewController, index: Int) -> UIViewController? {
        let stepController = storyboard?.instantiateViewControllerWithIdentifier("StepContentViewController") as! StepContentViewController
        stepController.stepId = index
        return stepController
    } 
}

extension StepsViewController : RGPageViewControllerDelegate {
    func heightForTabAtIndex(index: Int) -> CGFloat {
        return 44.0 
    }
    
    // use this to set a custom width for a tab
    func widthForTabAtIndex(index: Int) -> CGFloat {
        let tabSize = lesson?.steps[index].block.name.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(17)])
        if let size = tabSize {
            return size.width + 32
        }
        return 150
    }
}