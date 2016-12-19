
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

class CoursesViewController: UIViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var tableView = UITableView()
    
    var loadEnrolled : Bool? = nil
    var loadFeatured : Bool? = nil
    var refreshEnabled : Bool = true
    
    var lastUser: User?
    
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
        self.tableView.alignLeading("0", trailing: "0", to: self.view)
        self.tableView.alignTop("0", bottom: "0", to: self.view)
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.register(UINib(nibName: "CourseTableViewCell", bundle: nil), forCellReuseIdentifier: "CourseTableViewCell")
        tableView.register(UINib(nibName: "RefreshTableViewCell", bundle: nil), forCellReuseIdentifier: "RefreshTableViewCell")
        
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        if refreshEnabled {
            refreshControl?.addTarget(self, action: #selector(CoursesViewController.refreshCourses), for: .valueChanged)
            tableView.addSubview(refreshControl ?? UIView())
            refreshControl?.beginRefreshing()
            getCachedCourses(completion: {
                self.refreshCourses()
            })
            
        }
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        lastUser = AuthInfo.shared.user
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if refreshEnabled && (self.refreshControl?.isRefreshing ?? false) {
            let offset = self.tableView.contentOffset
            self.refreshControl?.endRefreshing()
            self.refreshControl?.beginRefreshing()
            self.tableView.contentOffset = offset
        }
        if lastUser != AuthInfo.shared.user {
            refreshControl?.beginRefreshing()
            getCachedCourses(completion: {
                self.refreshCourses()
            })
        }
    }
    
    fileprivate func getCachedCourses(completion: ((Void) -> Void)?) {
        isRefreshing = true
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            do {
                let cachedIds = self.tabIds 
                let c = try Course.getCourses(cachedIds)
                self.courses = Sorter.sort(c, byIds: cachedIds)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }       
                completion?()
            }
            catch {
                print("Error while fetching data from store")
            }
        }
    }
    
    
    func onRefresh() {
    }
    
    
    func refreshCourses() {
        isRefreshing = true
        performRequest({
            ApiDataDownloader.sharedDownloader.getDisplayedCoursesIds(featured: self.loadFeatured, enrolled: self.loadEnrolled, page: 1, success: { 
                (ids, meta) -> Void in
                ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .update, success: { 
                    (newCourses) -> Void in
                    
                    self.courses = Sorter.sort(newCourses, byIds: ids)
                    self.meta = meta
                    self.currentPage = 1
                    self.tabIds = ids
					
                    DispatchQueue.main.async {
						self.onRefresh()
                        self.emptyDatasetState = .empty
                        self.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    }
					
                    self.lastUser = AuthInfo.shared.user
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
            }, error:  {
                self.handleRefreshError()
        })
    }
    
    var emptyDatasetState : EmptyDatasetState = .empty {
        didSet {
            UIThread.performUI{
                self.tableView.reloadEmptyDataSet()
            }
        }
    }
    
    func handleRefreshError() {
        self.isRefreshing = false
        DispatchQueue.main.async {
            //TODO: Handle refresh error here - just add some kind of message or smth
            self.emptyDatasetState = EmptyDatasetState.connectionError
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
    
    func refreshingChangedTo(_ refreshing: Bool) {
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
        performRequest({ 
            () -> Void in
            ApiDataDownloader.sharedDownloader.getDisplayedCoursesIds(featured: self.loadFeatured, enrolled: self.loadEnrolled, page: self.currentPage + 1, success: { 
                (idsImmutable, meta) -> Void in
                var ids = idsImmutable
                ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .update, success: { 
                    (newCoursesImmutable) -> Void in
                    var newCourses = newCoursesImmutable
                    newCourses = self.getNonExistingCourses(newCourses)
                    ids = ids.flatMap{
                        id in
                        return newCourses.index{$0.id == id} != nil ? id : nil
                    }
                    
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
            }, error:  {
                self.handleLoadMoreError()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCourse" {
            let dvc = segue.destination as! CoursePreviewViewController
            dvc.course = sender as? Course
            dvc.hidesBottomBarWhenPushed = true
        }
        
        if segue.identifier == "showSections" {
            let dvc = segue.destination as! SectionsViewController
            dvc.course = sender as? Course
            dvc.hidesBottomBarWhenPushed = true
        }
        
        if segue.identifier == "showPreferences" {
            let dvc = segue.destination
            dvc.hidesBottomBarWhenPushed = true
        }
    }
    
    func getNonExistingCourses(_ newCourses: [Course]) -> [Course] {
        return newCourses.flatMap{
            newCourse in
            if let _ = courses.index(where: {$0 == newCourse}) {
                return nil
            } else {
                return newCourse
            }
        }
    }
}


extension CoursesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == courses.count && needRefresh() {
            return 60
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if courses[(indexPath as NSIndexPath).row].enrolled {
            self.performSegue(withIdentifier: "showSections", sender: courses[(indexPath as NSIndexPath).row])
        } else {
            self.performSegue(withIdentifier: "showCourse", sender: courses[(indexPath as NSIndexPath).row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CoursesViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return courses.count + (needRefresh() ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == courses.count && needRefresh() {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RefreshTableViewCell", for: indexPath) as! RefreshTableViewCell
            cell.initWithMessage("Loading new courses...", isRefreshing: !self.failedLoadingMore, refreshAction: { self.loadNextPage() })
            
            //            loadNextPage()
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseTableViewCell", for: indexPath) as! CourseTableViewCell
        
        cell.initWithCourse(courses[(indexPath as NSIndexPath).row])
        
        return cell
    }
}
