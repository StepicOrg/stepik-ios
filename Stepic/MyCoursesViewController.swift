//
//  FindCoursesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

class MyCoursesViewController: UIViewController {
    
    //    let TAB_NUMBER = 1
    let LOAD_ENROLLED : Bool? = true
    let LOAD_FEATURED : Bool? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        UICustomizer.sharedCustomizer.setStepicTabBar(self.tabBarController?.tabBar)
        
        tableView.registerNib(UINib(nibName: "CourseTableViewCell", bundle: nil), forCellReuseIdentifier: "CourseTableViewCell")
        tableView.registerNib(UINib(nibName: "RefreshTableViewCell", bundle: nil), forCellReuseIdentifier: "RefreshTableViewCell")
        
        refreshControl.addTarget(self, action: "refreshCourses", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        refreshControl.beginRefreshing()
        getCachedCourses(completion: {
            self.refreshCourses()
        })
        
        // Do any additional setup after loading the view.
    }
    
    private func getCachedCourses(completion completion: (Void -> Void)?) {
        isRefreshing = true
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            do {
                let cachedIds = TabsInfo.myCoursesIds 
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
        AuthentificationManager.sharedManager.autoRefreshToken { 
            () -> Void in
            ApiDataDownloader.sharedDownloader.getDisplayedCoursesIds(featured: self.LOAD_FEATURED, enrolled: self.LOAD_ENROLLED, page: 1, success: { 
                (ids, meta) -> Void in
                ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .Update, success: { 
                    (newCourses) -> Void in
                    
                    self.courses = Sorter.sort(newCourses, byIds: ids)
//                    self.courses = newCourses
                    self.meta = meta
                    self.currentPage = 1
                    TabsInfo.myCoursesIds = ids

                    dispatch_async(dispatch_get_main_queue()) {
                        self.refreshControl.endRefreshing()
                        self.tableView.reloadData()
                    }
                    self.isRefreshing = false
                    }, failure: { 
                        (error) -> Void in
                        print("failed downloading courses data in refresh")
                        self.isRefreshing = false
                })
                
                }, failure: { 
                    (error) -> Void in
                    print("failed refreshing course ids in refresh")
                    self.isRefreshing = false
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.refreshControl.endRefreshing()
                    }
                    
            })
        }
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
    
    private var isLoadingMore = false
    private var isRefreshing = false
    private var currentPage = 1
    
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
        AuthentificationManager.sharedManager.autoRefreshToken { 
            () -> Void in
            ApiDataDownloader.sharedDownloader.getDisplayedCoursesIds(featured: self.LOAD_FEATURED, enrolled: self.LOAD_ENROLLED, page: self.currentPage + 1, success: { 
                (ids, meta) -> Void in
                ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .Update, success: { 
                    (newCourses) -> Void in
                    
                    self.currentPage += 1
                    self.courses += Sorter.sort(newCourses, byIds: ids)
                    self.meta = meta
                    TabsInfo.myCoursesIds += ids

                    dispatch_async(dispatch_get_main_queue()) {
                        self.refreshControl.endRefreshing()
                        self.tableView.reloadData()
                    }
                    
                    self.isLoadingMore = false
                    }, failure: { 
                        (error) -> Void in
                        print("failed downloading courses data in Next")
                        self.isLoadingMore = false
                })
                
                }, failure: { 
                    (error) -> Void in
                    print("failed refreshing course ids in Next")
                    self.isLoadingMore = false
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.refreshControl.endRefreshing()
                    }
                    
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCourse" {
            let dvc = segue.destinationViewController as! CoursePreviewViewController
            dvc.course = courses[(sender as! NSIndexPath).row]
        }
        
        if segue.identifier == "showSections" {
            let dvc = segue.destinationViewController as! SectionsViewController
            dvc.course = courses[(sender as! NSIndexPath).row]
        }
    }
}


extension MyCoursesViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == courses.count && needRefresh() {
            return 60
        } else {
            return 100
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if courses[indexPath.row].enrolled {
            self.performSegueWithIdentifier("showSections", sender: indexPath)
        } else {
            self.performSegueWithIdentifier("showCourse", sender: indexPath)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension MyCoursesViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return courses.count + (needRefresh() ? 1 : 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == courses.count && needRefresh() {
            let cell = tableView.dequeueReusableCellWithIdentifier("RefreshTableViewCell", forIndexPath: indexPath) as! RefreshTableViewCell
            cell.initWithMessage("Loading new courses...")
            
            loadNextPage()
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseTableViewCell", forIndexPath: indexPath) as! CourseTableViewCell
        
        cell.initWithCourse(courses[indexPath.row])
        
        return cell
    }
}