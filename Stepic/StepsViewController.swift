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
    
    
    lazy var activityView : UIView = self.initActivityView()
    
    lazy var warningView : UIView = self.initWarningView()
    
    let warningViewTitle = NSLocalizedString("ConnectionErrorText", comment: "")
    
    func initWarningView() -> UIView {
        //TODO: change warning image!
        let v = WarningView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), delegate: self, text: warningViewTitle, image: Images.noWifiImage.size250x250, width: UIScreen.mainScreen().bounds.width - 16, contentMode: DeviceInfo.isIPad() ? UIViewContentMode.Bottom : UIViewContentMode.ScaleAspectFit)
        self.view.insertSubview(v, aboveSubview: self.view)
        v.alignTop("50", leading: "0", bottom: "0", trailing: "0", toView: self.view)
        return v
    }
    
    func initActivityView() -> UIView {
        let v = UIView()
        let ai = UIActivityIndicatorView()
        ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        ai.constrainWidth("50", height: "50")
        ai.color = UIColor.stepicGreenColor()
        v.backgroundColor = UIColor.whiteColor()
        v.addSubview(ai)
        ai.alignCenterWithView(v)
        ai.startAnimating()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.alignTop("50", leading: "0", bottom: "0", trailing: "0", toView: self.view)
        v.hidden = false
        return v
    }
    
    var doesPresentActivityIndicatorView : Bool = false {
        didSet {
            if doesPresentActivityIndicatorView {
                UIThread.performUI{self.activityView.hidden = false}
            } else {
                UIThread.performUI{self.activityView.hidden = true}
            }
        }
    }
    
    var doesPresentWarningView : Bool = false {
        didSet {
            if doesPresentWarningView {
                UIThread.performUI{self.warningView.hidden = false}
            } else {
                UIThread.performUI{self.warningView.hidden = true}
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = lesson?.title

        datasource = self
        delegate = self
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        UICustomizer.sharedCustomizer.setStepicTabBar(self.tabBarController?.tabBar)

        if numberOfPagesForViewController(self) == 0 {
            self.view.userInteractionEnabled = false
        }
        
        refreshSteps()
    }
    
    private func refreshSteps() {
        if numberOfPagesForViewController(self) == 0 {
            self.view.userInteractionEnabled = false
            self.doesPresentWarningView = false
            self.doesPresentActivityIndicatorView = true
        }
        lesson?.loadSteps(completion: {
            print("did reload data")
            UIThread.performUI{
                self.view.userInteractionEnabled = true
                self.reloadData()
                self.doesPresentWarningView = false
                self.doesPresentActivityIndicatorView = false
            }
            }, error: {
                errorText in
                print("error while loading steps in stepsviewcontroller")
                UIThread.performUI{
                    self.view.userInteractionEnabled = true
                    self.doesPresentActivityIndicatorView = false
                    if self.numberOfPagesForViewController(self) == 0 {
                        self.doesPresentWarningView = true
                    }
                }
            }, onlyLesson: context == .Lesson)
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
}



extension StepsViewController : RGPageViewControllerDataSource {
    func numberOfPagesForViewController(pageViewController: RGPageViewController) -> Int {
        return lesson?.steps.count ?? 0
    }
    
    func tabViewForPageAtIndex(pageViewController: RGPageViewController, index: Int) -> UIView {
        if let step = lesson?.steps[index] {
            let tabView = StepTabView(frame: CGRect(x: 0, y: 0, width: 25, height: 25), image: step.block.image, stepId: step.id)
            return tabView
        } else {
            return UIView()
        }
    }
    
    func viewControllerForPageAtIndex(pageViewController: RGPageViewController, index: Int) -> UIViewController? {
        if lesson!.steps[index].block.name == "video" {
            let stepController = storyboard?.instantiateViewControllerWithIdentifier("VideoStepViewController") as! VideoStepViewController
            stepController.video = lesson!.steps[index].block.video!
            stepController.nItem = self.navigationItem
            stepController.step = lesson!.steps[index]
            stepController.parentNavigationController = self.navigationController
            if context == .Unit {
                stepController.assignment = lesson!.unit?.assignments[index]
            }
            return stepController
        } else {
            let stepController = storyboard?.instantiateViewControllerWithIdentifier("WebStepViewController") as! WebStepViewController
            stepController.parent = self
            stepController.step = lesson!.steps[index]
            stepController.lesson = lesson
            stepController.stepId = index + 1
            stepController.nItem = self.navigationItem
            if context == .Unit {
                stepController.assignment = lesson!.unit?.assignments[index]
            }
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
    }
}

extension StepsViewController : WarningViewDelegate {
    func didPressButton() {
        refreshSteps()
    }
}