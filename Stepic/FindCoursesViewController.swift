//
//  FindCoursesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

class FindCoursesViewController: UIViewController {

    let TAB_NUMBER = 1
    let LOAD_ENROLLED : Bool? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        UICustomizer.sharedCustomizer.setStepicTabBar(self.tabBarController?.tabBar)
        tableView.registerNib(UINib(nibName: "CourseTableViewCell", bundle: nil), forCellReuseIdentifier: "CourseTableViewCell")
        tableView.registerNib(UINib(nibName: "RefreshTableViewCell", bundle: nil), forCellReuseIdentifier: "RefreshTableViewCell")

        refreshControl.addTarget(self, action: "refreshCourses", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        getCachedCourses()
        
        refreshControl.beginRefreshing()
        refreshCourses()
        // Do any additional setup after loading the view.
    }

//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return UIStatusBarStyle.LightContent
//    }
//    
    
    private func getCachedCourses() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            do {
                self.courses = try Course.getCourses(tabNumber: self.TAB_NUMBER)
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }            
            }
            catch {
                print("error while getting courses")
                self.courses = []
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshCourses() {
        isRefreshing = true
        ApiDataDownloader.sharedDownloader.getCoursesWithFeatured(true, enrolled: self.LOAD_ENROLLED, page: 1, tabNumber: TAB_NUMBER, success: {
            (courses, meta) in
            self.courses = courses
            CoreDataHelper.instance.save()
            self.meta = meta
            self.tableView.reloadData()
            self.isRefreshing = false
            self.currentPage = 1
            self.refreshControl.endRefreshing()
            }, failure: {
                error in 
                print("Failed refreshing courses")
                self.isRefreshing = false
                self.refreshControl.endRefreshing()
        })
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
        ApiDataDownloader.sharedDownloader.getCoursesWithFeatured(true, enrolled: self.LOAD_ENROLLED, page: currentPage + 1, tabNumber: TAB_NUMBER, success: {
            (courses, meta) in
            self.currentPage += 1
            self.courses += courses
            self.meta = meta
            self.tableView.reloadData()
            self.isLoadingMore = false
            
            }, failure: {
                error in 
                print("Next courses not loaded")
                self.isLoadingMore = false
        })
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


extension FindCoursesViewController : UITableViewDelegate {
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
    }
}

extension FindCoursesViewController : UITableViewDataSource {
    
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