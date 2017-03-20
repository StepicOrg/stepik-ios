
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
import SVProgressHUD

class CoursesViewController: UIViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var tableView = UITableView()
    
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
                self.handleCourseUpdates()
                self.refreshCourses()
            })
        } else {
            self.handleCourseUpdates()
        }
    }
    
    func handleCourseUpdates() {
        //override this method in subclass
    }
    
    fileprivate func getCachedCourses(completion: ((Void) -> Void)?) {
        isRefreshing = true
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            do {
                let cachedIds = self.tabIds 
                let c = try Course.getCourses(cachedIds)
                self.courses = Sorter.sort(c, byIds: cachedIds)
                print("got cached courses \(self.courses.count): \(cachedIds)\n")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    completion?()
                }       
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
            _ = ApiDataDownloader.sharedDownloader.getDisplayedCoursesIds(featured: self.loadFeatured, enrolled: self.loadEnrolled, isPublic: self.loadPublic, order: self.loadOrder, page: 1, success: { 
                (ids, meta) -> Void in
                _ = ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .update, success: { 
                    [weak self]
                    (newCourses) -> Void in
                    
                    guard let s = self else { return }
                    
                    let coursesCompletion = {
                        s.courses = Sorter.sort(newCourses, byIds: ids)
                        s.meta = meta
                        s.currentPage = 1
                        s.tabIds = ids
                        
                        DispatchQueue.main.async {
                            s.onRefresh()
                            s.emptyDatasetState = .empty
                            s.refreshControl?.endRefreshing()
                            s.tableView.reloadData()
                        }
                        
                        s.lastUser = AuthInfo.shared.user
                        s.isRefreshing = false
                    }
                    
                    var progressIds : [String] = []
                    var progresses : [Progress] = []
                    var lastStepIds : [String] = []
                    var lastSteps : [LastStep] = []
                    for course in newCourses {
                        if let progressId = course.progressId {
                            progressIds += [progressId]
                        }
                        if let progress = course.progress {
                            progresses += [progress]
                        }
                        
                        if let lastStepId = course.lastStepId {
                            lastStepIds += [lastStepId]
                        }
                        if let lastStep = course.lastStep {
                            lastSteps += [lastStep]
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
                        error in
                        coursesCompletion()
                        print("Error while dowloading progresses")
                    })
                    
                    
                }, failure: { 
                    [weak self]
                    error in
                    print("failed downloading courses data in refresh")
                    self?.handleRefreshError()
                })
                
            }, failure: { 
                [weak self]
                error in
                print("failed refreshing course ids in refresh")
                self?.handleRefreshError()
            })
        }, error:  {
            [weak self] 
            error in
            guard let s = self else { return }
            if error == PerformRequestError.noAccessToRefreshToken {
                AuthInfo.shared.token = nil
                RoutingManager.auth.routeFrom(controller: s, success: {
                    [weak self] in 
                    self?.getCachedCourses(completion: {
                        self?.refreshCourses()
                    })
                }, cancel: nil)
            }
            self?.handleRefreshError()
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
            _ = ApiDataDownloader.sharedDownloader.getDisplayedCoursesIds(featured: self.loadFeatured, enrolled: self.loadEnrolled, isPublic: self.loadPublic, order: self.loadOrder, page: self.currentPage + 1, success: { 
                (idsImmutable, meta) -> Void in
                var ids = idsImmutable
                _ = ApiDataDownloader.sharedDownloader.getCoursesByIds(ids, deleteCourses: Course.getAllCourses(), refreshMode: .update, success: { 
                    [weak self]
                    (newCoursesImmutable) -> Void in
                    guard let s = self else { return }
                    var newCourses = newCoursesImmutable
                    newCourses = s.getNonExistingCourses(newCourses)
                    ids = ids.flatMap{
                        id in
                        return newCourses.index{$0.id == id} != nil ? id : nil
                    }
                    
                    s.currentPage += 1
                    s.courses += Sorter.sort(newCourses, byIds: ids)
                    s.meta = meta
                    s.tabIds += ids
                    //                        self.refreshControl.endRefreshing()
                    UIThread.performUI{s.tableView.reloadData()}
                    
                    
                    s.isLoadingMore = false
                    s.failedLoadingMore = false
                    }, failure: { 
                        [weak self]
                        error in
                        print("failed downloading courses data in Next")
                        self?.handleLoadMoreError()
                })
                
                }, failure: { 
                    [weak self]
                    error in
                    print("failed refreshing course ids in Next")
                    self?.handleLoadMoreError()
                    
            })
            }, error: {
                [weak self] 
                error in
                guard let s = self else { return }
                if error == PerformRequestError.noAccessToRefreshToken {
                    AuthInfo.shared.token = nil
                    RoutingManager.auth.routeFrom(controller: s, success: {
                        [weak self] in 
                        self?.getCachedCourses(completion: {
                            self?.refreshCourses()
                        })
                    }, cancel: nil)
                }
                self?.handleLoadMoreError()
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
    
    func continueLearning(course: Course) {
        guard let lastStep = course.lastStep else {
            return
        }
        
        guard 
        let sectionsVC = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as? SectionsViewController,
        let unitsVC = ControllerHelper.instantiateViewController(identifier: "UnitsViewController") as? UnitsViewController,
        let stepsVC = ControllerHelper.instantiateViewController(identifier: "StepsViewController") as? StepsViewController else {
            return
        }
        
        sectionsVC.course = course
        sectionsVC.hidesBottomBarWhenPushed = true
        unitsVC.unitId = lastStep.unitId
        stepsVC.stepId = lastStep.stepId
        stepsVC.unitId = lastStep.unitId

        if lastStep.unitId != nil && lastStep.stepId != nil {
            navigationController?.pushViewController(sectionsVC, animated: false)
            navigationController?.pushViewController(unitsVC, animated: false)
            navigationController?.pushViewController(stepsVC, animated: true)
            AnalyticsReporter.reportEvent(AnalyticsEvents.Continue.stepOpened, parameters: nil)
        } else {
            navigationController?.pushViewController(sectionsVC, animated: true)
            AnalyticsReporter.reportEvent(AnalyticsEvents.Continue.sectionsOpened, parameters: nil)
        }
        
    }
    
    func continuePressed(course: Course) {
        SVProgressHUD.show()
        
        guard let lastStepId = course.lastStepId else {
            return
        }
        
        let errorBlock = {
            [weak self] in
            DispatchQueue.main.async {
                if course.lastStep != nil {
                    SVProgressHUD.showSuccess(withStatus: "")
                    self?.continueLearning(course: course)
                } else {
                    SVProgressHUD.showError(withStatus: "")
                }
            }
        }
        
        let successBlock = {
            [weak self] in
            DispatchQueue.main.async {
                SVProgressHUD.showSuccess(withStatus: "")
                self?.continueLearning(course: course)
            }
        }
        
        print("LastStep stepId before refresh: \(course.lastStep?.stepId)")
        _ = ApiDataDownloader.lastSteps.retrieve(ids: [lastStepId], updatingLastSteps: course.lastStep != nil ? [course.lastStep!] : [] , success: {
            [weak self]
            newLastSteps -> Void in
            
            guard let newLastStep = newLastSteps.first, 
                (newLastSteps.count > 0 && newLastSteps.count < 2) else {
                errorBlock()
                return
            }

            print("new stepId \(newLastStep.stepId)")
            
            course.lastStep = newLastStep
            CoreDataHelper.instance.save()
            successBlock()
            
        }, error: {
            error in
            print("Error while downloading last step")
            errorBlock()
        })
    }
}


extension CoursesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == courses.count && needRefresh() {
            return 60
        } else {
            return 126
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
        
        let course = courses[(indexPath as NSIndexPath).row]
        cell.initWithCourse(course)
        cell.continueAction = {
            [weak self] in
            self?.continuePressed(course: course)
        }
        
        return cell
    }
}
