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
import Alamofire

class SearchResultsCoursesViewController: CoursesViewController {
    
    var parentVC : UIViewController?
    
    var query : String = "" {
        didSet {
            if self.query != oldValue {
                self.isLoadingMore = false
                self.currentRequest?.cancel()
                refreshCourses()
            }
        }
    }
    
    override func refreshingChangedTo(_ refreshing: Bool) {
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
        ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        ai.constrainWidth("50", height: "50")
        ai.color = UIColor.stepicGreenColor()
        v.backgroundColor = UIColor.white
        v.addSubview(ai)
        ai.alignCenter(with: v)
        ai.startAnimating()
        self.view.insertSubview(v, aboveSubview: tableView)
        v.align(to: self.view)
        v.isHidden = false
        return v
    }
    
    var doesPresentActivityIndicatorView : Bool = false {
        didSet {
            if doesPresentActivityIndicatorView {
                print("present activity indicator view")
                UIThread.performUI{self.activityView.isHidden = false}
            } else {
                print("dismiss activity indicator view")
                UIThread.performUI{self.activityView.isHidden = true}
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
        print("tableView frame resultsController active -> \(tableView.convert(tableView.bounds, to: nil))")
        print("before change resultsController active content offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset)")
        if tableView.contentInset.top != 60 {
            tableView.contentInset = UIEdgeInsets(top: 60.0, left: 0, bottom: 0, right: 0)
            tableView.setContentOffset(CGPoint(x: 0, y: -60.0), animated: true)
            tableView.layoutIfNeeded()
        }
        
        print("after change resultsController active content offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let constraintDistance = tableView.convert(tableView.bounds, to: nil).minY
        let totalDistance = constraintDistance + tableView.contentInset.top
        if totalDistance != 64 {
            tableView.contentInset = UIEdgeInsets(top: 64.0 - constraintDistance, left: 0, bottom: 0, right: 0)
            //            print("searchResults insets changed")
            view.layoutIfNeeded()
        }
        //        print("\n didLayoutSubviews searchResults: tableViewDistance -> \(constraintDistance), offset -> \(tableView.contentOffset), inset -> \(tableView.contentInset), frame -> \(tableView.frame)\n")
    }
    
    var currentRequest : Request?
    
    override func refreshCourses() {
        isRefreshing = true
        performRequest({ 
            [weak self]
            () -> Void in
            if let s = self {
                s.currentRequest = ApiDataDownloader.sharedDownloader.search(query: s.query, type: "course", page: 1, success: { 
                    (searchResults, meta) -> Void in
                    let ids = searchResults.flatMap({return $0.courseId})
                    
                    s.currentRequest = ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .update, success: { 
                        (newCourses) -> Void in
                        
                        s.courses = Sorter.sort(newCourses, byIds: ids)
                        s.meta = meta
                        s.currentPage = 1
                        DispatchQueue.main.async {
                            s.refreshControl?.endRefreshing()
                            s.tableView.reloadData()
                        }
                        s.isRefreshing = false
                        }, failure: { 
                            (error) -> Void in
                            print("failed downloading courses data in refresh")
                            s.handleRefreshError()
                        
                    })
                    
                    }, error: { 
                        (error) -> Void in
                        print("failed refreshing course ids in refresh")
                        s.handleRefreshError()
                })
            }
            }, error:  {
                self.handleRefreshError()
        })
    }
    
    override func loadNextPage() {
        if isRefreshing || isLoadingMore {
            return
        }
        
        isLoadingMore = true
        //TODO : Check if it should be executed in another thread
        performRequest({ 
            () -> Void in
            ApiDataDownloader.sharedDownloader.search(query: self.query, type: "course", page: self.currentPage + 1, success: { 
                (searchResults, meta) -> Void in
                let ids = searchResults.flatMap({return $0.courseId})
                ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .update, success: { 
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
            }, error:  {
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
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        if identifier == "showCourse" || identifier == "showSections" { 
            parentVC?.performSegue(withIdentifier: identifier, sender: sender)
        } else {
            super.performSegue(withIdentifier: identifier, sender: sender)
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
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let pvc = parentVC as? FindCoursesViewController
        pvc?.hideKeyboardIfNeeded()
    }
}

extension SearchResultsCoursesViewController {
    func imageForEmptyDataSet(_ scrollView: UIScrollView!) -> UIImage! {
        return Images.emptyCoursesPlaceholder
    }
    
    func titleForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = NSLocalizedString("NoSearchResultsTitle", comment: "")
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0),
                          NSForegroundColorAttributeName: UIColor.darkGray]
        
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
    
    func backgroundColorForEmptyDataSet(_ scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func verticalOffsetForEmptyDataSet(_ scrollView: UIScrollView!) -> CGFloat {
        //        print("offset -> \((self.navigationController?.navigationBar.bounds.height) ?? 0 + UIApplication.sharedApplication().statusBarFrame.height)")
        return 0
    }
}

extension SearchResultsCoursesViewController {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return false
    }
    
    func emptyDataSetDidTapView(_ scrollView: UIScrollView!) {
        let pvc = parentVC as? FindCoursesViewController
        pvc?.hideKeyboardIfNeeded()
    }
}
