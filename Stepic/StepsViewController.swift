//
//  StepsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

enum StepsControllerPresentationContext {
    case Lesson, Unit
}

class StepsViewController: RGPageViewController {

    //TODO: really need optionals here?
    var lesson : Lesson?
    var startStepId : Int?
    
    //By default presentation context is unit
    var context : StepsControllerPresentationContext = .Unit
    
//    var controllers : [UIViewController?]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = lesson?.title

        datasource = self
        delegate = self
        SVProgressHUD.showWithStatus("", maskType: SVProgressHUDMaskType.Clear)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        UICustomizer.sharedCustomizer.setStepicTabBar(self.tabBarController?.tabBar)

        lesson?.loadSteps(completion: {
            print("did reload data")
            UIThread.performUI{self.reloadData()}
        }, onlyLesson: context == .Lesson)
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = " "
        if let l = lesson, id = startStepId {
            if l.steps.count != 0 {
                print("id -> \(id)")
                self.selectTabAtIndex(id, updatePage: true)
            }
        }
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
            return 8.0
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
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        iv.setImageWithColor(image: lesson?.steps[index].block.image ?? Constants.placeholderImage, color: UIColor.whiteColor())
//        iv.image = lesson?.steps[index].block.image//Constants.placeholderImage
        iv.contentMode = UIViewContentMode.ScaleAspectFit
//        let tabView = UILabel()
//        
//        tabView.font = UIFont.systemFontOfSize(17)
//        tabView.text = lesson?.steps[index].block.name
//        tabView.textColor = UIColor.whiteColor()
//        tabView.sizeToFit()
        return iv
    }
    
    func viewControllerForPageAtIndex(pageViewController: RGPageViewController, index: Int) -> UIViewController? {
        if lesson!.steps[index].block.name == "video" {
            let stepController = storyboard?.instantiateViewControllerWithIdentifier("VideoStepViewController") as! VideoStepViewController
            stepController.video = lesson!.steps[index].block.video!
            stepController.nItem = self.navigationItem
            stepController.step = lesson!.steps[index]
            if context == .Unit {
                stepController.assignment = lesson!.unit?.assignments[index]
            }
            return stepController
        } else {
            let stepController = storyboard?.instantiateViewControllerWithIdentifier("WebStepViewController") as! WebStepViewController
            stepController.step = lesson!.steps[index]
            stepController.lesson = lesson
            stepController.stepId = index + 1
            stepController.nItem = self.navigationItem
            if context == .Unit {
                stepController.assignment = lesson!.unit?.assignments[index]
            }
            //            stepController.navigationVC = self.navigationController!
            return stepController
        }
    } 
}

extension StepsViewController : RGPageViewControllerDelegate {
    func heightForTabAtIndex(index: Int) -> CGFloat {
        return 44.0 
    }
    
    // use this to set a custom width for a tab
    func widthForTabAtIndex(index: Int) -> CGFloat {
        return 44.0
//        let tabSize = lesson?.steps[index].block.name.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(17)])
//        if let size = tabSize {
//            return size.width + 32
//        }
//        return 150
    }
}