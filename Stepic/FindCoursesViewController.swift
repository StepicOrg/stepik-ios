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
        let constraintDistance = tableView.convert(tableView.bounds, to: nil).minY
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
        loadFeatured = nil
        loadPublic = true
        loadOrder = "-activity"
        
        searchResultsVC = ControllerHelper.instantiateViewController(identifier: "SearchResultsCoursesViewController") as! SearchResultsCoursesViewController
        searchResultsVC.parentVC = self
        searchController = UISearchController(searchResultsController: searchResultsVC)
        
        searchController.searchBar.searchBarStyle = UISearchBarStyle.default
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.barTintColor = UIColor.stepicGreenColor()
        searchController.searchBar.tintColor = UIColor.white
        UITextField.appearanceWhenContained(within: [UISearchBar.self]).tintColor = UIColor.defaultDwonloadButtonBlue()

        self.automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.scopeButtonTitles = []
        
        
        super.viewDidLoad()

        self.tableView.backgroundView = UIView()
        self.tableView.backgroundColor = UIColor.lightText

        self.navigationItem.titleView = self.searchController.searchBar
    }
    
}

extension FindCoursesViewController : UISearchControllerDelegate {
}

extension FindCoursesViewController : UISearchBarDelegate {
}

extension FindCoursesViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let results = searchController.searchResultsController as? SearchResultsCoursesViewController
        results?.query = searchController.searchBar.text!
    }
}

extension FindCoursesViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideKeyboardIfNeeded()
    }
}

extension FindCoursesViewController {
    
    func imageForEmptyDataSet(_ scrollView: UIScrollView!) -> UIImage! {
        switch emptyDatasetState {
        case .empty:
            return Images.emptyCoursesPlaceholder
        case .connectionError:
            return Images.noWifiImage.size250x250
        }
    }
    
    func titleForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        switch emptyDatasetState {
        case .empty:
            text = NSLocalizedString("EmptyFindCoursesTitle", comment: "")
            break
        case .connectionError:
            text = NSLocalizedString("ConnectionErrorTitle", comment: "")
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
            text = NSLocalizedString("EmptyFindCoursesDescription", comment: "")
            break
        case .connectionError:
            text = NSLocalizedString("ConnectionErrorPullToRefresh", comment: "")
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
    
    func backgroundColorForEmptyDataSet(_ scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func verticalOffsetForEmptyDataSet(_ scrollView: UIScrollView!) -> CGFloat {
        //        print("offset -> \((self.navigationController?.navigationBar.bounds.height) ?? 0 + UIApplication.sharedApplication().statusBarFrame.height)")
        return 44
    }
}

extension FindCoursesViewController  {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}
