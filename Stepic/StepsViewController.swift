//
//  StepsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class StepsViewController: RGPageViewController, RGPageViewControllerDelegate {

    var lesson : Lesson?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datasource = self
        delegate = self
        
        lesson?.loadSteps(completion: {
            self.reloadData()
        })
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        tabView.sizeToFit()
        return tabView
    }
    
    func viewControllerForPageAtIndex(pageViewController: RGPageViewController, index: Int) -> UIViewController? {
        let stepController = storyboard?.instantiateViewControllerWithIdentifier("StepContentViewController") as! StepContentViewController
        stepController.stepId = index
        return stepController
    } 
}