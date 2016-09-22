//
//  MyCoursesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class MyCoursesViewController: CoursesViewController {
    
    override var tabIds :  [Int] {
        get {
            return TabsInfo.myCoursesIds
        }
        
        set(value) {
            TabsInfo.myCoursesIds = value
        }
    }
    
    override func viewDidLoad() {
        loadEnrolled = true
        loadFeatured = nil
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        handleCourseUpdates()
    }
    
    private func getExistingIndexPathsFromCourses(newCourses: [Course]) -> [NSIndexPath] {
        return newCourses.flatMap{ 
            newCourse in
            return courses.indexOf{$0 == newCourse}
            }.map{
                return NSIndexPath(forRow: $0, inSection: 0)
        }
    }
    
    
    func handleCourseUpdates() {
        if CoursesJoinManager.sharedManager.hasUpdates {
            print("deleting courses -> \(CoursesJoinManager.sharedManager.deletedCourses.count)")
            print("adding courses -> \(CoursesJoinManager.sharedManager.addedCourses.count)")
            
            self.tableView.beginUpdates()
            
            let deletingIndexPaths = getExistingIndexPathsFromCourses(CoursesJoinManager.sharedManager.deletedCourses)
            tableView.deleteRowsAtIndexPaths(deletingIndexPaths, withRowAnimation: .Automatic)
            for index in deletingIndexPaths.sort({$0.row > $1.row}) {
                courses.removeAtIndex(index.row)
                tabIds.removeAtIndex(index.row)
            }
            
            let addedCourses = getNonExistingCourses(CoursesJoinManager.sharedManager.addedCourses)
            if addedCourses.count != 0 { 
                courses = addedCourses + courses
                tabIds = tabIds + courses.map{return $0.id}
                tableView.insertRowsAtIndexPaths((0..<addedCourses.count).map({return NSIndexPath(forRow: $0, inSection: 0)}), withRowAnimation: .Automatic)
            }
            
            self.tableView.endUpdates()
            
            CoursesJoinManager.sharedManager.clean()
        }
    }
    
}

extension MyCoursesViewController {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        switch emptyDatasetState {
        case .Empty:
            return Images.emptyCoursesPlaceholder
        case .ConnectionError:
            return Images.noWifiImage.size250x250
        }
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        switch emptyDatasetState {
        case .Empty:
            text = NSLocalizedString("EmptyMyCoursesTitle", comment: "")
            break
        case .ConnectionError:
            text = NSLocalizedString("ConnectionErrorTitle", comment: "")
            break
        }
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0),
            NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        
        switch emptyDatasetState {
        case .Empty:
            if !AuthInfo.shared.isAuthorized {
                text = NSLocalizedString("SignInToJoin", comment: "")
            } else {
                text = NSLocalizedString("EmptyMyCoursesDescription", comment: "")
            }

            break
        case .ConnectionError:
            text = NSLocalizedString("ConnectionErrorPullToRefresh", comment: "")
            break
        }
                
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14.0),
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        var text : String = ""
        switch emptyDatasetState {
        case .Empty:
            if !AuthInfo.shared.isAuthorized {
                text = NSLocalizedString("SignIn", comment: "")
            } else {
                text = NSLocalizedString("AllCourses", comment: "")
            }

            
            break
        case .ConnectionError:
            text = ""
            break
        }
        
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(16.0),
                          NSForegroundColorAttributeName: UIColor.stepicGreenColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.whiteColor()
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
//        print("offset -> \((self.navigationController?.navigationBar.bounds.height) ?? 0 + UIApplication.sharedApplication().statusBarFrame.height)")
        return 44
    }
}

extension MyCoursesViewController  {
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        switch emptyDatasetState {
        case .Empty:
            if !AuthInfo.shared.isAuthorized {
                let vc = ControllerHelper.getAuthController()
                self.presentViewController(vc, animated: true, completion: nil)
            } else {
                self.tabBarController?.selectedIndex = 1
            }
           
            
            break
        case .ConnectionError:
            break
        }
    }
}