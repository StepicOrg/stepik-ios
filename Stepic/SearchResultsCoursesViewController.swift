//
//  SearchResultsCoursesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class SearchResultsCoursesViewController: CoursesViewController {

    var query : String = "" {
        didSet {
            self.isLoadingMore = false
            refreshCourses()
        }
    }
    
    override func viewDidLoad() {
        refreshEnabled = false
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
            ApiDataDownloader.sharedDownloader.search(query: self.query, type: "course", page: 1, success: { 
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

}
