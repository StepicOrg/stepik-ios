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
        
    override var tabIds :  [Int] {
        get {
            return TabsInfo.allCoursesIds
        }
        
        set(value) {
            TabsInfo.allCoursesIds = tabIds
        }
    }
    
    func hideKeyboardIfNeeded() {
        self.searchController.searchBar.resignFirstResponder()
    }
    
    func printInfo() {
        print("\n------------------")
        if searchController.active {
            print("tableView frame empty resultsController searchController active -> \(tableView.convertRect(tableView.bounds, toView: nil))")
            print("before change empty resultsController searchController active content offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset)")
            if tableView.contentInset.top != 60 {
                tableView.contentInset = UIEdgeInsets(top: 60.0, left: 0, bottom: 0, right: 0)
                tableView.setContentOffset(CGPoint(x: 0, y: -60.0), animated: true)
                tableView.layoutIfNeeded()
            }
            
            print("after change empty resultsController searchController active content offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset)")
            
        } else {
            print("tableView frame searchController inactive -> \(tableView.convertRect(tableView.bounds, toView: nil))")
            
            print("before change searchController inactive content offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset)")
            
            
            //            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0, bottom: 0, right: 0)
            tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            tableView.layoutIfNeeded()
            
            print("after change searchController inactive content offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tableViewDistance = tableView.convertRect(tableView.bounds, toView: nil).minY

//        print("\n willAppear findCourses: tableViewDistance -> \(tableViewDistance), offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset)\n")
//        print(tableView.convertRect(tableView.bounds, toView: nil))
//        let tableViewDistance = tableView.convertRect(tableView.bounds, toView: nil).minY
//        
//        print("\nfindCourses: tableViewDistance -> \(tableViewDistance), offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset), navigationBar -> \(navigationController?.navigationBar.hidden)\n")
//        tableViewTopConstraint.constant = 0 - tableViewDistance
//        view.layoutIfNeeded()
//        
//        if searchController.active {
//            if tableView.contentInset.top != 60 {
//                tableView.contentInset = UIEdgeInsets(top: 60.0, left: 0, bottom: 0, right: 0)
//                tableView.layoutIfNeeded()
//            }
//        } else {            
//            //            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0, bottom: 0, right: 0)
//            tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//            tableView.layoutIfNeeded()
//        }
        //        print(refreshControl)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let constraintDistance = tableView.convertRect(tableView.bounds, toView: nil).minY
        let totalDistance = constraintDistance + tableView.contentInset.top
        let oldInset = tableView.contentInset.top
        if totalDistance != 64 && totalDistance != 124 {
//            print("changing findCourses inset programmatically. Constraint distance -> \(constraintDistance), totalDistance -> \(totalDistance), new inset -> \(64.0 - totalDistance)")
            tableView.contentInset = UIEdgeInsets(top: 64.0 - constraintDistance, left: 0, bottom: 0, right: 0)
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y + (oldInset - tableView.contentInset.top)), animated: true)
//            print("findCourses insets changed")
            view.layoutIfNeeded()
        }
//        print("\n didLayoutSubviews findCourses: tableViewDistance -> \(constraintDistance), offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset), frame -> \(tableView.frame)\n")
    }
    
    var topConstraint : NSLayoutConstraint?
    
    override func viewDidLoad() {
        
        loadEnrolled = nil
        loadFeatured = true
        //        self.extendedLayoutIncludesOpaqueBars = true
        
        searchResultsVC = ControllerHelper.instantiateViewController(identifier: "SearchResultsCoursesViewController") as! SearchResultsCoursesViewController
        searchResultsVC.parentVC = self
        searchController = UISearchController(searchResultsController: searchResultsVC)
        
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Default
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor.stepicGreenColor()
        searchController.searchBar.tintColor = UIColor.whiteColor()
        UITextField.appearanceWhenContainedWithin([UISearchBar.self]).tintColor = UIColor.defaultDwonloadButtonBlueColor()
//        UITextField.appearanceWhenContainedIn([UISearchBar.self], nil)
//        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = UIColor.lightGrayColor()

        self.automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = []
        //        tableView.tableHeaderView = searchController.searchBar
        //        searchController.searchBar.clipsToBounds = true
        
//        topConstraint = tableView.constrainTopSpaceToView(view, predicate: "0")[0] as! NSLayoutConstraint
        
        super.viewDidLoad()
        //        self.tableView.setContentOffset(CGPointMake(0, -self.refreshControl.frame.size.height), animated:true)
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundColor = UIColor.lightTextColor()
        //        initStatusBarView()
        //        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.titleView = self.searchController.searchBar
    }
    
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
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText == "" {
//            self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//            tableView.layoutIfNeeded()
//        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        print("\ndid begin editing\n")
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        print("\ndid end editing\n")
    }
}

extension FindCoursesViewController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        print("updated search results")
        let results = searchController.searchResultsController as? SearchResultsCoursesViewController
        results?.query = searchController.searchBar.text!
    }
}