//
//  ViewController.swift
//  StepicTV
//
//  Created by Anton Kondrashov on 11/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CoursesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var loadEnrolled : Bool? = nil
    var loadFeatured : Bool? = nil
    var loadPublic : Bool? = nil
    var loadOrder: String? = nil
    
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CourseTableViewCell", bundle: nil), forCellReuseIdentifier: "CourseTableViewCell")
        tableView.register(UINib(nibName: "RefreshTableViewCell", bundle: nil), forCellReuseIdentifier: "RefreshTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshCourses()
        
    }

    
    func refreshCourses() {
        performRequest({
            ApiDataDownloader.sharedDownloader.getDisplayedCoursesIds(featured: true, enrolled: false, isPublic: true, order: nil, page: 1, success: {
                (ids, meta) -> Void in
                ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .update, success: {
                    (newCourses) -> Void in
                    
                    let coursesCompletion = {
                        self.courses = Sorter.sort(newCourses, byIds: ids)
                        self.meta = meta
                        self.currentPage = 1
                        self.tabIds = ids
                        
                        DispatchQueue.main.async {
//                            self.emptyDatasetState = .empty
//                            self.refreshControl?.endRefreshing()
                            self.tableView.reloadData()
                        }
                        
                        self.lastUser = AuthInfo.shared.user
                        self.isRefreshing = false
                    }
                    
                    var progressIds : [String] = []
                    var progresses : [Progress] = []
                    for course in newCourses {
                        if let progressId = course.progressId {
                            progressIds += [progressId]
                        }
                        if let progress = course.progress {
                            progresses += [progress]
                        }
                    }
                    
                    _ = ApiDataDownloader.sharedDownloader.getProgressesByIds(progressIds, deleteProgresses: progresses,refreshMode: .update, success: {
                        (newProgresses) -> Void in
                        progresses = Sorter.sort(newProgresses, byIds: progressIds)
                        for i in 0 ..< min(newCourses.count, progresses.count) {
                            newCourses[i].progress = progresses[i]
                        }
                        
                        CoreDataHelper.instance.save()
                        coursesCompletion()
                    }, failure: {
                        (error) -> Void in
                        coursesCompletion()
                        print("Error while dowloading progresses")
                    })
                    
                    
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
    
    func loadNextPage() {
        if isRefreshing || isLoadingMore {
            return
        }
        
        isLoadingMore = true
        //TODO : Check if it should be executed in another thread
        performRequest({
            () -> Void in
            ApiDataDownloader.sharedDownloader.getDisplayedCoursesIds(featured: self.loadFeatured, enrolled: self.loadEnrolled, isPublic: self.loadPublic, order: self.loadOrder, page: self.currentPage + 1, success: {
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
    
    func handleRefreshError() {
        self.isRefreshing = false
    }
    func handleLoadMoreError() {
        self.isLoadingMore = false
        self.failedLoadingMore = true
    }
}

extension CoursesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == courses.count && needRefresh() {
            return 60
        } else {
            return 300
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return (indexPath as NSIndexPath).row < courses.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard (indexPath as NSIndexPath).row < courses.count else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
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
