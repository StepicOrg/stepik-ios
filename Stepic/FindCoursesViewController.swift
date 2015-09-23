//
//  FindCoursesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

class FindCoursesViewController: UIViewController {

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
        refreshControl.beginRefreshing()
        refreshCourses()
        // Do any additional setup after loading the view.
    }

//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return UIStatusBarStyle.LightContent
//    }
//    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshCourses() {
        isRefreshing = true
        ApiDataDownloader.sharedDownloader.getCoursesWithFeatured(true, enrolled: nil, page: 1, success: {
            (courses, meta) in
            self.courses = courses
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
        ApiDataDownloader.sharedDownloader.getCoursesWithFeatured(true, enrolled: nil, page: currentPage + 1, success: {
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
    
}


extension FindCoursesViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == courses.count && needRefresh() {
            return 60
        } else {
            return 100
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