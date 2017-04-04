//
//  MyCoursesViewController.swift
//  Stepic
//
//  Created by Anton Kondrashov on 28/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//
import UIKit

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
        }
    }
    
}
