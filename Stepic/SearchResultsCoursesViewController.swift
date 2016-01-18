//
//  SearchResultsCoursesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import FLKAutoLayout

class SearchResultsCoursesViewController: CoursesViewController {

    var parentVC : UIViewController?
        
    var query : String = "" {
        didSet {
            if self.query != oldValue {
                self.isLoadingMore = false
                refreshCourses()
            }
        }
    }
    
    override func refreshingChangedTo(refreshing: Bool) {
        if refreshing {
            doesPresentActivityIndicatorView = true
            print(activityView.frame)
        } else {
            doesPresentActivityIndicatorView = false
        }
    }
    
    lazy var activityView : UIView = self.initActivityView()
    
    func initActivityView() -> UIView {
        let v = UIView()
        let ai = UIActivityIndicatorView()
        ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        ai.constrainWidth("50", height: "50")
        ai.color = UIColor.stepicGreenColor()
        v.backgroundColor = UIColor.whiteColor()
        v.addSubview(ai)
        ai.alignCenterWithView(v)
        ai.startAnimating()
        self.view.insertSubview(v, aboveSubview: tableView)
        v.alignToView(self.view)
        v.hidden = false
        return v
    }
    
    var doesPresentActivityIndicatorView : Bool = false {
        didSet {
            if doesPresentActivityIndicatorView {
                print("present activity indicator view")
                UIThread.performUI{self.activityView.hidden = false}
            } else {
                print("dismiss activity indicator view")
                UIThread.performUI{self.activityView.hidden = true}
            }
        }
    }
    
    override func viewDidLoad() {
        refreshEnabled = false
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self

        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.        
    }
    
    func printInfo() {
        print("\n------------------")
        print("tableView frame resultsController active -> \(tableView.convertRect(tableView.bounds, toView: nil))")
        print("before change resultsController active content offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset)")
        if tableView.contentInset.top != 60 {
            tableView.contentInset = UIEdgeInsets(top: 60.0, left: 0, bottom: 0, right: 0)
            tableView.setContentOffset(CGPoint(x: 0, y: -60.0), animated: true)
            tableView.layoutIfNeeded()
        }
        
        print("after change resultsController active content offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let constraintDistance = tableView.convertRect(tableView.bounds, toView: nil).minY
        let totalDistance = constraintDistance + tableView.contentInset.top
        if totalDistance != 64 {
            tableView.contentInset = UIEdgeInsets(top: 64.0 - constraintDistance, left: 0, bottom: 0, right: 0)
//            print("searchResults insets changed")
            view.layoutIfNeeded()
        }
//        print("\n didLayoutSubviews searchResults: tableViewDistance -> \(constraintDistance), offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset), frame -> \(tableView.frame)\n")
    }
    
    override func refreshCourses() {
        isRefreshing = true
        AuthentificationManager.sharedManager.autoRefreshToken(success: { 
            () -> Void in
            ApiDataDownloader.sharedDownloader.search(query: self.query, type: "course", page: 1, success: { 
                (searchResults, meta) -> Void in
                let ids = searchResults.flatMap({return $0.courseId})
                
                ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .Update, success: { 
                    (newCourses) -> Void in
                    
                    self.courses = Sorter.sort(newCourses, byIds: ids)
                    self.meta = meta
                    self.currentPage = 1
                    dispatch_async(dispatch_get_main_queue()) {
                        self.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    }
                    self.isRefreshing = false
                    }, failure: { 
                        (error) -> Void in
                        print("failed downloading courses data in refresh")
                        self.handleRefreshError()
                })
                
                }, error: { 
                    (error) -> Void in
                    print("failed refreshing course ids in refresh")
                    self.handleRefreshError()
                    
            })
            }, failure:  {
                self.handleRefreshError()
        })
    }
    
    override func loadNextPage() {
        if isRefreshing || isLoadingMore {
            return
        }
        
        isLoadingMore = true
        //TODO : Check if it should be executed in another thread
        AuthentificationManager.sharedManager.autoRefreshToken(success: { 
            () -> Void in
            ApiDataDownloader.sharedDownloader.search(query: self.query, type: "course", page: self.currentPage + 1, success: { 
                (searchResults, meta) -> Void in
                let ids = searchResults.flatMap({return $0.courseId})
                ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .Update, success: { 
                    (newCourses) -> Void in
                    
                    if !self.isLoadingMore {
                        return
                    }
                    
                    self.currentPage += 1
                    self.courses += Sorter.sort(newCourses, byIds: ids)
                    self.meta = meta
                    //                        self.refreshControl.endRefreshing()
                    UIThread.performUI{self.tableView.reloadData()}
                    
                    
                    self.isLoadingMore = false
                    self.failedLoadingMore = false
                    }, failure: { 
                        (error) -> Void in
                        print("failed downloading courses data in Next")
                        self.handleLoadMoreError()
                })
                
                }, error: { 
                    (error) -> Void in
                    print("failed refreshing course ids in Next")
                    self.handleLoadMoreError()
                    
            })
            }, failure:  {
                self.handleLoadMoreError()
        })
    }
    
    override func handleRefreshError() {
        self.isRefreshing = false
        courses = []
        UIThread.performUI{ self.tableView.reloadData() }
        if let vc = parentVC { 
            UIThread.performUI{ Messages.sharedManager.showConnectionErrorMessage(inController: vc.navigationController!) }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
        if identifier == "showCourse" || identifier == "showSections" { 
            parentVC?.performSegueWithIdentifier(identifier, sender: sender)
        } else {
            super.performSegueWithIdentifier(identifier, sender: sender)
        }
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

extension SearchResultsCoursesViewController {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        let pvc = parentVC as? FindCoursesViewController
        pvc?.hideKeyboardIfNeeded()
    }
}

extension SearchResultsCoursesViewController : DZNEmptyDataSetSource {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return Images.emptyCoursesPlaceholder
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = NSLocalizedString("NoSearchResultsTitle", comment: "")
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0),
            NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
//    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
//        
//        let text = NSLocalizedString("EmptyMyCoursesDescription", comment: "")
//        
//        let paragraph = NSMutableParagraphStyle()
//        paragraph.lineBreakMode = .ByWordWrapping
//        paragraph.alignment = .Center
//        
//        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14.0),
//            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
//            NSParagraphStyleAttributeName: paragraph]
//        
//        return NSAttributedString(string: text, attributes: attributes)
//    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.whiteColor()
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        //        print("offset -> \((self.navigationController?.navigationBar.bounds.height) ?? 0 + UIApplication.sharedApplication().statusBarFrame.height)")
        return 0
    }
}

extension SearchResultsCoursesViewController : DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return false
    }
    
    func emptyDataSetDidTapView(scrollView: UIScrollView!) {
        let pvc = parentVC as? FindCoursesViewController
        pvc?.hideKeyboardIfNeeded()
    }
}
