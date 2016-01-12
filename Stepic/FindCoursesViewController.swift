//
//  FindCoursesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout
class FindCoursesViewController: CoursesViewController {
    
    var searchResultsVC : SearchResultsCoursesViewController! 
    var searchController : UISearchController!
    
    var filteredCourses = [Course]()
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    override var tabIds :  [Int] {
        get {
            return TabsInfo.allCoursesIds
        }
        
        set(value) {
            TabsInfo.allCoursesIds = tabIds
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if searchController.active {
            tableView.contentInset = UIEdgeInsets(top: 60.0, left: 0, bottom: 0, right: 0)
            print("searchController active content offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset)")
        } else {
            print("searchController inactive content offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset)")
        }
        print(refreshControl)
    }
    
    
    override func viewDidLoad() {
        
        loadEnrolled = nil
        loadFeatured = true
        //        self.extendedLayoutIncludesOpaqueBars = true
        
        searchResultsVC = ControllerHelper.instantiateViewController(identifier: "SearchResultsCoursesViewController") as! SearchResultsCoursesViewController
        searchController = UISearchController(searchResultsController: searchResultsVC)
        
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Default
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
//        searchController.searchBar.showsCancelButton = false
//        searchController.searchBar.
        searchController.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor.stepicGreenColor()
        searchController.searchBar.tintColor = UIColor.whiteColor()
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = []
        //        tableView.tableHeaderView = searchController.searchBar
        //        searchController.searchBar.clipsToBounds = true
        
        super.viewDidLoad()
        //        self.tableView.setContentOffset(CGPointMake(0, -self.refreshControl.frame.size.height), animated:true)
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundColor = UIColor.lightTextColor()
        //        initStatusBarView()
        //        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.titleView = self.searchController.searchBar
        
    }
    
//////    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//////        if searchController.active && searchController.searchBar.text != "" {
//////            return filteredCourses.count
//////        } 
//////        return courses.count + (needRefresh() ? 1 : 0)
//////        
//////    } 
//////    
//////    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//////        if searchController.active && searchController.searchBar.text != "" {
//////            let cell = tableView.dequeueReusableCellWithIdentifier("CourseTableViewCell", forIndexPath: indexPath) as! CourseTableViewCell
//////            
//////            cell.initWithCourse(filteredCourses[indexPath.row])
//////            
//////            return cell
//////        } 
//////        if indexPath.row == courses.count && needRefresh() {
//////            let cell = tableView.dequeueReusableCellWithIdentifier("RefreshTableViewCell", forIndexPath: indexPath) as! RefreshTableViewCell
//////            cell.initWithMessage("Loading new courses...", isRefreshing: !failedLoadingMore, refreshAction: { self.loadNextPage() })
//////            
//////            //            loadNextPage()
//////            
//////            return cell
//////        }
//////        
//////        let cell = tableView.dequeueReusableCellWithIdentifier("CourseTableViewCell", forIndexPath: indexPath) as! CourseTableViewCell
//////        
//////        cell.initWithCourse(courses[indexPath.row])
//////        
//////        return cell
//////    }
//////    
//////    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//////        if searchController.active && searchController.searchBar.text != "" {
//////            return 100
//////        } 
//////        if indexPath.row == courses.count && needRefresh() {
//////            return 60
//////        } else {
//////            return 100
//////        }
//////    }
//////    
//////    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//////        
//////        if searchController.active && searchController.searchBar.text != "" {
//////            if filteredCourses[indexPath.row].enrolled {
//////                self.performSegueWithIdentifier("showSections", sender: indexPath)
//////            } else {
//////                self.performSegueWithIdentifier("showCourse", sender: indexPath)
//////            }
//////            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//////        } else {
//////            
//////            if courses[indexPath.row].enrolled {
//////                self.performSegueWithIdentifier("showSections", sender: indexPath)
//////            } else {
//////                self.performSegueWithIdentifier("showCourse", sender: indexPath)
//////            }
//////            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//////        }
//////    }
////    
////    func filterContentForSearchText(searchText: String) {
////        filteredCourses = courses.filter({( course : Course) -> Bool in
////            return course.title.lowercaseString.containsString(searchText.lowercaseString)
////        })
////        tableView.reloadData()
////    } 
//    
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if searchController.active && searchController.searchBar.text != "" {
//            if segue.identifier == "showCourse" {
//                let dvc = segue.destinationViewController as! CoursePreviewViewController
//                dvc.course = filteredCourses[(sender as! NSIndexPath).row]
//            }
//            
//            if segue.identifier == "showSections" {
//                let dvc = segue.destinationViewController as! SectionsViewController
//                dvc.course = filteredCourses[(sender as! NSIndexPath).row]
//            }
//            
//            if segue.identifier == "showPreferences" {
//                let dvc = segue.destinationViewController as! UserPreferencesTableViewController
//                dvc.hidesBottomBarWhenPushed = true
//            }
//        } else {
//            if segue.identifier == "showCourse" {
//                let dvc = segue.destinationViewController as! CoursePreviewViewController
//                dvc.course = courses[(sender as! NSIndexPath).row]
//            }
//            
//            if segue.identifier == "showSections" {
//                let dvc = segue.destinationViewController as! SectionsViewController
//                dvc.course = courses[(sender as! NSIndexPath).row]
//            }
//            
//            if segue.identifier == "showPreferences" {
//                let dvc = segue.destinationViewController as! UserPreferencesTableViewController
//                dvc.hidesBottomBarWhenPushed = true
//            }
//        }
//    }
    
    override func viewDidLayoutSubviews() {
//        print("\n\ndid layout subviews\n\n")
        //        print("searchStatusBarView frame -> \(searchStatusBarView.frame)")
        //        self.searchController.searchBar.sizeToFit()
    }
    //    var oldRefresh : UIRefreshControl?
    
    //    var searchStatusBarView = UIView()
    //    var searchStatusBarHeight : NSLayoutConstraint!
    //    
    //    func initStatusBarView() {
    //        self.view.addSubview(searchStatusBarView)
    //        self.searchStatusBarView.alignLeading("0", trailing: "0", toView: self.view)
    //        self.searchStatusBarView.alignTopEdgeWithView(self.view, predicate: "0")
    //        self.searchStatusBarView.backgroundColor = UIColor(red: 198/255.0, green: 198/255.0, blue: 203/255.0, alpha: 1)
    //        self.searchStatusBarView.alpha = 1
    //        searchStatusBarHeight = self.searchStatusBarView.constrainHeight("0")[0] as! NSLayoutConstraint
    //    }
    
//    var newRefresh: UIRefreshControl {
//        get {
//            let rc = UIRefreshControl()
//            rc.addTarget(self, action: "refreshCourses", forControlEvents: .ValueChanged)
//            return rc
//        }
//    }
}

extension FindCoursesViewController : UISearchControllerDelegate {
    func willPresentSearchController(searchController: UISearchController) {
        print("will present")
        
        //        searchStatusBarHeight.constant = 27
        
        //        UIView.animateWithDuration(0.2, animations: {
        //            self.view.layoutIfNeeded()
        //        })
        
//        refreshControl?.removeFromSuperview()
//        refreshControl = nil
        ////        tableViewTopConstraint.constant = -20
        ////        self.view.layoutIfNeeded()
        //        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        //        tableView.setContentOffset(CGPointMake(0, -20), animated: true)
        //        self.tableView.setContentOffset(CGPointMake(0, -20), animated:true)
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        //        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //        UIView.animateWithDuration(0.2, animations: {
        //            self.tableView.layoutIfNeeded()
        //        })
        
        //        searchStatusBarHeight.constant = 0
        //        UIView.animateWithDuration(0.4, animations: {
        //            self.view.layoutIfNeeded()
        //        })       
    }
    
    func didDismissSearchController(searchController: UISearchController) {
//        print(refreshControl)
//        refreshControl = newRefresh
//        tableView.addSubview(refreshControl ?? UIView())
        print("did dismiss")
        //        tableView.setContentOffset(CGPointMake(0, 0), animated: true)
        
        //        self.tableView.setContentOffset(CGPointMake(0, 0), animated:true)
        //        tableViewTopConstraint.constant = 0
        //        self.view.layoutIfNeeded()
    }
}

extension FindCoursesViewController : UISearchBarDelegate {
    
}

extension FindCoursesViewController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print("updated search results")
        let results = searchController.searchResultsController as? SearchResultsCoursesViewController
        results?.query = searchController.searchBar.text!
    }
}