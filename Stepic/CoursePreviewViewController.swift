//
//  CoursePreviewViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 30.09.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class CoursePreviewViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
        
    var course : Course? = nil
    
    var displayingInfoType : DisplayingInfoType = .Overview 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        
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
    
    @IBAction func displayingSegmentedControlValueChanged(sender: UISegmentedControl) {
        displayingInfoType = sender.selectedSegmentIndex == 0 ? .Overview : .Detailed
//        tableView.reloadData()
        reloadTableView()
    }
    
    @IBAction func joinButtonPressed(sender: UIButton) {
        
    }
    
    
    func reloadTableView() {
        var changingIndexPaths : [NSIndexPath] = []
        for i in 0..<2 {
            changingIndexPaths += [NSIndexPath(forRow: i, inSection: 1)]
        }
        tableView.reloadRowsAtIndexPaths(changingIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}

extension CoursePreviewViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return course == nil ? 0 : 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        default: 
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0  { 
            let cell = tableView.dequeueReusableCellWithIdentifier("IntroVideoTableViewCell", forIndexPath: indexPath) as! IntroVideoTableViewCell
            
            cell.initWithCourse(course!)
            return cell
        } else {
            
            if displayingInfoType == .Overview {
                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCellWithIdentifier("TeachersTableViewCell", forIndexPath: indexPath) as! TeachersTableViewCell
                    cell.initWithCourse(course!)
                    return cell
                
                case 1:
                    let cell = tableView.dequeueReusableCellWithIdentifier("SummaryTableViewCell", forIndexPath: indexPath) as! SummaryTableViewCell
                    cell.initWithCourse(course!)
                    return cell
                default:
                    let cell = tableView.dequeueReusableCellWithIdentifier("DefaultTableViewCell", forIndexPath: indexPath)
                    return cell
                }
            } else {
                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCellWithIdentifier("DescriptionTableViewCell", forIndexPath: indexPath) as! DescriptionTableViewCell
                    cell.initWithCourse(course!)
                    return cell
                case 1:
                    let cell = tableView.dequeueReusableCellWithIdentifier("DateInfoTableViewCell", forIndexPath: indexPath) as! DateInfoTableViewCell
                    cell.initWithCourse(course!)
                    return cell
                default:
                    let cell = tableView.dequeueReusableCellWithIdentifier("DefaultTableViewCell", forIndexPath: indexPath)
                    return cell

                }
            }
        }
            
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 1 {
            let cv = UIView()
            cv.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            return cv
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("GeneralInfoTableViewCell") as! GeneralInfoTableViewCell
        cell.initWithCourse(course!)
        
        cell.typeSegmentedControl.selectedSegmentIndex = displayingInfoType == .Overview ? 0 : 1
        let cFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: cell.frame.height)
        cell.frame = cFrame
        let cv = UIView()
        cv.addSubview(cell)
        
        return cv
    }
    
}

extension CoursePreviewViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0  { 
            let w = UIScreen.mainScreen().bounds.width
            return w * (9/16)
        } else {
            
            if displayingInfoType == .Overview {
                switch indexPath.row {
                case 0:
                    return 137
                    
                case 1:
                    return SummaryTableViewCell.heightForCourse(course!)
                default:
                    return 0
                }
                
            } else {
                switch indexPath.row {
                case 0:
                    return DescriptionTableViewCell.heightForCourse(course!)
                    
                case 1:
                    return 67
                default:
                    return 0
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 120
        }
    }
}

extension CoursePreviewViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView == self.tableView) {
            if (scrollView.contentOffset.y < 0) {
                scrollView.contentOffset = CGPointZero
            }
        }
    }
}