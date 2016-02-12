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
    
    //Returns tuple of unique non-intersecting and intersecting courses
    private func findUniqueIntersectionsBetween(courses1 : [Course], and courses2: [Course]) -> ([Course], [Course]){
        var notIntersected = [Course]()
        var intersected = [Course]()

        for course in courses2 {
            if let _ = courses1.indexOf(course) {
                if let _ = intersected.indexOf(course) {
                    print("wow, there are non-unique courses!")
                } else {
                    intersected += [course]
                } 
            } else {
                if let _ = notIntersected.indexOf(course) {
                    print("wow, there are non-unique courses!")
                } else {
                    notIntersected += [course]
                }
            }
        }
        
        return (notIntersected, intersected)
    }
    
//    private func getNonExistingCourses(newCourses: [Course]) -> [Course] {
//        return newCourses.flatMap{
//            newCourse in
//            if let _ = courses.indexOf({$0 == newCourse}) {
//                return nil
//            } else {
//                return newCourse
//            }
//        }
//    }
    
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
//                if courses.count == addedCourses.count {
//                    tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
//                }
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
            text = NSLocalizedString("EmptyMyCoursesDescription", comment: "")
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
}