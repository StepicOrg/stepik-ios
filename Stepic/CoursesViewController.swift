//
//  CoursesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout
import DZNEmptyDataSet

class CoursesViewController: UIViewController {
    
    var tableView = UITableView()
    
    var loadEnrolled : Bool? = nil
    var loadFeatured : Bool? = nil
    var refreshEnabled : Bool = true
    
    //need to override in subclass
    var tabIds : [Int] {
        get {
            return []
        }
        
        set(value) {
        }
    }
    
    var refreshControl : UIRefreshControl? = UIRefreshControl()
    
    override func viewDidLoad() {        
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        self.tableView.alignLeading("0", trailing: "0", toView: self.view)
        self.tableView.alignTop("0", bottom: "0", toView: self.view)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        UICustomizer.sharedCustomizer.setStepicTabBar(self.tabBarController?.tabBar)
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.registerNib(UINib(nibName: "CourseTableViewCell", bundle: nil), forCellReuseIdentifier: "CourseTableViewCell")
        tableView.registerNib(UINib(nibName: "RefreshTableViewCell", bundle: nil), forCellReuseIdentifier: "RefreshTableViewCell")
        
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        if refreshEnabled {
            refreshControl?.addTarget(self, action: "refreshCourses", forControlEvents: .ValueChanged)
            tableView.addSubview(refreshControl ?? UIView())
            refreshControl?.beginRefreshing()
            getCachedCourses(completion: {
                self.refreshCourses()
            })
        }
        
        // Do any additional setup after loading the view.
        print("loadFeatured = \(loadFeatured)")
        print("loadEnrolled = \(loadEnrolled)")
        //        loadFeatured = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        print(tableView.frame)
        if refreshEnabled && (self.refreshControl?.refreshing ?? false) {
            let offset = self.tableView.contentOffset
            self.refreshControl?.endRefreshing()
            self.refreshControl?.beginRefreshing()
            self.tableView.contentOffset = offset
        }
    }
    
    private func getCachedCourses(completion completion: (Void -> Void)?) {
        isRefreshing = true
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            do {
                let cachedIds = self.tabIds 
                let c = try Course.getCourses(cachedIds)
                self.courses = Sorter.sort(c, byIds: cachedIds)
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }       
                completion?()
            }
            catch {
                print("Error while fetching data from store")
            }
        }
    }
    
    
    func refreshCourses() {
        isRefreshing = true
        AuthentificationManager.sharedManager.autoRefreshToken(success: { 
            () -> Void in
            ApiDataDownloader.sharedDownloader.getDisplayedCoursesIds(featured: self.loadFeatured, enrolled: self.loadEnrolled, page: 1, success: { 
                (ids, meta) -> Void in
                ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .Update, success: { 
                    (newCourses) -> Void in
                    
                    self.courses = Sorter.sort(newCourses, byIds: ids)
                    self.meta = meta
                    self.currentPage = 1
                    self.tabIds = ids
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
                
                }, failure: { 
                    (error) -> Void in
                    print("failed refreshing course ids in refresh")
                    self.handleRefreshError()
                    
            })
            }, failure:  {
                self.handleRefreshError()
        })
    }
    
    func handleRefreshError() {
        self.isRefreshing = false
        dispatch_async(dispatch_get_main_queue()) {
            Messages.sharedManager.showConnectionErrorMessage(inController: self.navigationController!)
            self.refreshControl?.endRefreshing()
        }
    }
    
    func handleLoadMoreError() {
        self.isLoadingMore = false                        
        self.failedLoadingMore = true
        //        Messages.sharedManager.showConnectionErrorMessage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    var courses : [Course] = []
    var meta : Meta?
    
    var isLoadingMore = false
    var isRefreshing = false {
        didSet{
            self.refreshingChangedTo(isRefreshing)
        }
    }
    
    func refreshingChangedTo(refreshing: Bool) {
    }
    
    var currentPage = 1
    
    var failedLoadingMore = false {
        didSet {
            UIThread.performUI {
                self.tableView.reloadData()
            }        
        }
    }
    
    func needRefresh() -> Bool {
        if let m = meta {
            return m.hasNext
        } else {
            return false
        }
    }
    
    func loadNextPage() {
        if isRefreshing || isLoadingMore {
            return
        }
        
        isLoadingMore = true
        //TODO : Check if it should be executed in another thread
        AuthentificationManager.sharedManager.autoRefreshToken(success: { 
            () -> Void in
            ApiDataDownloader.sharedDownloader.getDisplayedCoursesIds(featured: self.loadFeatured, enrolled: self.loadEnrolled, page: self.currentPage + 1, success: { 
                (ids, meta) -> Void in
                ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .Update, success: { 
                    (newCourses) -> Void in
                    
                    self.currentPage += 1
                    self.courses += Sorter.sort(newCourses, byIds: ids)
                    self.meta = meta
                    self.tabIds += ids
                    //                        self.refreshControl.endRefreshing()
                    UIThread.performUI{self.tableView.reloadData()}
                    
                    
                    self.isLoadingMore = false
                    self.failedLoadingMore = false
                    }, failure: { 
                        (error) -> Void in
                        print("failed downloading courses data in Next")
                        self.handleLoadMoreError()
                })
                
                }, failure: { 
                    (error) -> Void in
                    print("failed refreshing course ids in Next")
                    self.handleLoadMoreError()
                    
            })
            }, failure:  {
                self.handleLoadMoreError()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCourse" {
            let dvc = segue.destinationViewController as! CoursePreviewViewController
            dvc.course = sender as? Course
        }
        
        if segue.identifier == "showSections" {
            let dvc = segue.destinationViewController as! SectionsViewController
            dvc.course = sender as? Course
        }
        
        if segue.identifier == "showPreferences" {
            let dvc = segue.destinationViewController as! UserPreferencesTableViewController
            dvc.hidesBottomBarWhenPushed = true
        }
    }
}


extension CoursesViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == courses.count && needRefresh() {
            return 60
        } else {
            return 100
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if courses[indexPath.row].enrolled {
            self.performSegueWithIdentifier("showSections", sender: courses[indexPath.row])
        } else {
            self.performSegueWithIdentifier("showCourse", sender: courses[indexPath.row])
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension CoursesViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return courses.count + (needRefresh() ? 1 : 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == courses.count && needRefresh() {
            let cell = tableView.dequeueReusableCellWithIdentifier("RefreshTableViewCell", forIndexPath: indexPath) as! RefreshTableViewCell
            cell.initWithMessage("Loading new courses...", isRefreshing: !self.failedLoadingMore, refreshAction: { self.loadNextPage() })
            
            //            loadNextPage()
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseTableViewCell", forIndexPath: indexPath) as! CourseTableViewCell
        
        cell.initWithCourse(courses[indexPath.row])
        
        return cell
    }
}