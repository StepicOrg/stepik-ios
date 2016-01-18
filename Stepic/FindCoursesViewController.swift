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
            TabsInfo.allCoursesIds = value
        }
    }
    
    func hideKeyboardIfNeeded() {
        self.searchController.searchBar.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let constraintDistance = tableView.convertRect(tableView.bounds, toView: nil).minY
        let totalDistance = constraintDistance + tableView.contentInset.top
        let oldInset = tableView.contentInset.top
        if totalDistance != 64 && totalDistance != 124 {
            tableView.contentInset = UIEdgeInsets(top: 64.0 - constraintDistance, left: 0, bottom: 0, right: 0)
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y + (oldInset - tableView.contentInset.top)), animated: true)
            view.layoutIfNeeded()
        }
    }
    
    var topConstraint : NSLayoutConstraint?
    
    override func viewDidLoad() {
        
        loadEnrolled = nil
        loadFeatured = true
        
        searchResultsVC = ControllerHelper.instantiateViewController(identifier: "SearchResultsCoursesViewController") as! SearchResultsCoursesViewController
        searchResultsVC.parentVC = self
        searchController = UISearchController(searchResultsController: searchResultsVC)
        
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Default
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.barTintColor = UIColor.stepicGreenColor()
        searchController.searchBar.tintColor = UIColor.whiteColor()
        UITextField.appearanceWhenContainedWithin([UISearchBar.self]).tintColor = UIColor.defaultDwonloadButtonBlueColor()

        self.automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.scopeButtonTitles = []
        
        
        super.viewDidLoad()

        self.tableView.backgroundView = UIView()
        self.tableView.backgroundColor = UIColor.lightTextColor()

        self.navigationItem.titleView = self.searchController.searchBar
    }
    
}

extension FindCoursesViewController : UISearchControllerDelegate {
}

extension FindCoursesViewController : UISearchBarDelegate {
}

extension FindCoursesViewController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let results = searchController.searchResultsController as? SearchResultsCoursesViewController
        results?.query = searchController.searchBar.text!
    }
}

extension FindCoursesViewController {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        hideKeyboardIfNeeded()
    }
}