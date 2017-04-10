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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Alerts.rate.present(alert: Alerts.rate.construct(), inController: self)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        handleCourseUpdates()
//    }
    
    fileprivate func getExistingIndexPathsFromCourses(_ newCourses: [Course]) -> [IndexPath] {
        return newCourses.flatMap{ 
            newCourse in
            return courses.index{$0 == newCourse}
            }.map{
                return IndexPath(row: $0, section: 0)
        }
    }
    
    override func onRefresh() {
        if #available(iOS 9.0, *) {
            WatchDataHelper.parseAndAddPlainCourses(self.courses)
        }
    }

    override func refreshBegan() {
        emptyDatasetState = .refreshing
    }
    
    override func handleCourseUpdates() {
        if CoursesJoinManager.sharedManager.hasUpdates {
            print("deleting courses -> \(CoursesJoinManager.sharedManager.deletedCourses.count)")
            print("adding courses -> \(CoursesJoinManager.sharedManager.addedCourses.count)")
            
            self.tableView.beginUpdates()
            
            let deletingIndexPaths = getExistingIndexPathsFromCourses(CoursesJoinManager.sharedManager.deletedCourses)
            tableView.deleteRows(at: deletingIndexPaths, with: .automatic)
            for index in deletingIndexPaths.sorted(by: {($0 as NSIndexPath).row > ($1 as NSIndexPath).row}) {
                courses.remove(at: (index as NSIndexPath).row)
                tabIds.remove(at: (index as NSIndexPath).row)
            }
            
            let addedCourses = getNonExistingCourses(CoursesJoinManager.sharedManager.addedCourses)
            if addedCourses.count != 0 { 
                print("before: \(courses)")
                courses = addedCourses + courses
                print("after: \(courses)")
                tabIds = tabIds + courses.map{return $0.id}
                tableView.insertRows(at: (0..<addedCourses.count).map({return IndexPath(row: $0, section: 0)}), with: .automatic)
            }
            
            self.tableView.endUpdates()
            
            CoursesJoinManager.sharedManager.clean()
            self.onRefresh()
        }
    }
    
}

extension MyCoursesViewController {
    func imageForEmptyDataSet(_ scrollView: UIScrollView!) -> UIImage! {
        switch emptyDatasetState {
        case .empty:
            return Images.emptyCoursesPlaceholder
        case .connectionError:
            return Images.noWifiImage.size250x250
        case .refreshing:
            return Images.emptyCoursesPlaceholder
        }
    }
    
    func titleForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        switch emptyDatasetState {
        case .empty:
            text = NSLocalizedString("EmptyMyCoursesTitle", comment: "")
            break
        case .connectionError:
            text = NSLocalizedString("ConnectionErrorTitle", comment: "")
            break
        case .refreshing:
            text = NSLocalizedString("Refreshing", comment: "")
            break

        }
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0),
            NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        
        switch emptyDatasetState {
        case .empty:
            if !AuthInfo.shared.isAuthorized {
                text = NSLocalizedString("SignInToJoin", comment: "")
            } else {
                text = NSLocalizedString("EmptyMyCoursesDescription", comment: "")
            }

            break
        case .connectionError:
            text = NSLocalizedString("ConnectionErrorPullToRefresh", comment: "")
            break
            
        case .refreshing:
            text = NSLocalizedString("RefreshingDescription", comment: "")
            break
        }
                
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0),
            NSForegroundColorAttributeName: UIColor.lightGray,
            NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitleForEmptyDataSet(_ scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        var text : String = ""
        switch emptyDatasetState {
        case .empty:
            if !AuthInfo.shared.isAuthorized {
                text = NSLocalizedString("SignIn", comment: "")
            } else {
                text = NSLocalizedString("AllCourses", comment: "")
            }

            
            break
        case .connectionError:
            text = ""
            break
            
        case .refreshing:
            text = ""
            break

        }
        
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0),
                          NSForegroundColorAttributeName: UIColor.stepicGreenColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func backgroundColorForEmptyDataSet(_ scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func verticalOffsetForEmptyDataSet(_ scrollView: UIScrollView!) -> CGFloat {
//        print("offset -> \((self.navigationController?.navigationBar.bounds.height) ?? 0 + UIApplication.sharedApplication().statusBarFrame.height)")
        return 44
    }
}

extension MyCoursesViewController  {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        switch emptyDatasetState {
        case .empty:
            if !AuthInfo.shared.isAuthorized {
                let vc = ControllerHelper.getAuthController()
                self.present(vc, animated: true, completion: nil)
            } else {
                self.tabBarController?.selectedIndex = 1
            }
           
            
            break
        case .connectionError:
            break
            
        case .refreshing:
            break
        }
    }
}
