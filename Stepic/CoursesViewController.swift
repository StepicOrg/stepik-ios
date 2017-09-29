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
import Alamofire

class CoursesViewController: UIViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIViewControllerPreviewingDelegate {

    var tableView = UITableView(frame: CGRect.zero, style: .plain)

    var loadEnrolled: Bool?
    var loadFeatured: Bool?
    var loadPublic: Bool?
    var loadOrder: String?

    var refreshEnabled: Bool = true
    var lastUser: User?

    //need to override in subclass
    var tabIds: [Int] {
        get {
            return []
        }

        set(value) {
        }
    }

    var refreshControl: UIRefreshControl? = UIRefreshControl()

    var shouldAlignTop: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(tableView)
        self.tableView.alignLeading("0", trailing: "0", toView: self.view)
        self.tableView.alignBottomEdge(withView: self.view, predicate: "0")
        if shouldAlignTop {
            self.tableView.alignTopEdge(withView: self.view, predicate: "0")
        }

        self.automaticallyAdjustsScrollViewInsets = false
        tableView.register(UINib(nibName: "CourseTableViewCell", bundle: nil), forCellReuseIdentifier: "CourseTableViewCell")
        tableView.register(UINib(nibName: "RefreshTableViewCell", bundle: nil), forCellReuseIdentifier: "RefreshTableViewCell")
        tableView.register(UINib(nibName: "CourseWidgetTableViewCell", bundle: nil), forCellReuseIdentifier: "CourseWidgetTableViewCell")

        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        #if swift(>=3.2)
            if #available(iOS 11.0, *) {
                tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
            }
        #endif

        if refreshEnabled {
            refreshControl?.addTarget(self, action: #selector(CoursesViewController.refreshCourses), for: .valueChanged)
            if #available(iOS 10.0, *) {
                tableView.refreshControl = refreshControl
            } else {
                tableView.addSubview(refreshControl ?? UIView())
            }
            refreshControl?.layoutIfNeeded()
            refreshControl?.beginRefreshing()
            getCachedCourses(completion: {
                self.refreshCourses()
            })

        }

        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self

        lastUser = AuthInfo.shared.user

        if(traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: view)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
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

    fileprivate func getCachedCourses(completion: (() -> Void)?) {
        isRefreshing = true
        DispatchQueue.global(qos: .default).async {
            do {
                let cachedIds = self.tabIds
                let c = try Course.getCourses(cachedIds)
                self.courses = Sorter.sort(c, byIds: cachedIds)
                print("got cached courses \(self.courses.count): \(cachedIds)\n")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    completion?()
                }
            } catch {
                print("Error while fetching data from store")
            }
        }
    }

    func onRefresh() {
    }

    func refreshBegan() {
    }

    func refreshCourses() {
        isRefreshing = true
        refreshBegan()
        performRequest({
            _ = ApiDataDownloader.courses.retrieveDisplayedIds(featured: self.loadFeatured, enrolled: self.loadEnrolled, isPublic: self.loadPublic, order: self.loadOrder, page: 1, success: {
                ids, meta -> Void in
                _ = ApiDataDownloader.courses.retrieve(ids: ids, existing: Course.getAllCourses(), refreshMode: .update, success: {
                    [weak self]
                    (newCourses) -> Void in

                    guard let s = self else { return }

                    let coursesCompletion = {
                        DispatchQueue.main.async {
                            s.tableView.reloadData()
                        }
                    }

                    s.courses = Sorter.sort(newCourses, byIds: ids)
                    s.meta = meta
                    s.currentPage = 1
                    s.tabIds = ids
                    s.lastUser = AuthInfo.shared.user
                    s.isRefreshing = false
                    s.onRefresh()
                    s.emptyDatasetState = .empty
                    s.refreshControl?.endRefreshing()
                    s.tableView.reloadData()

                    s.updateProgresses(forCourses: newCourses, completion: coursesCompletion)
                    s.updateReviewSummaries(forCourses: newCourses, completion: coursesCompletion)
                }, error: {
                    [weak self]
                    _ in
                    print("failed downloading courses data in refresh")
                    self?.handleRefreshError()
                })

            }, failure: {
                [weak self]
                _ in
                print("failed refreshing course ids in refresh")
                self?.handleRefreshError()
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
            self?.handleRefreshError()
        })
    }

    func matchProgresses(newProgresses: [Progress], ids progressIds: [String], courses: [Course]) {
        let progresses = Sorter.sort(newProgresses, byIds: progressIds)

        if progresses.count == 0 {
            CoreDataHelper.instance.save()
            return
        }

        var progressCnt = 0
        for i in 0 ..< courses.count {
            if courses[i].progressId == progresses[progressCnt].id {
                print("matched progress to course \(courses[i].id)")
                courses[i].progress = progresses[progressCnt]
                progressCnt += 1
            }
            if progressCnt == progresses.count {
                break
            }
        }
        CoreDataHelper.instance.save()
    }

    func matchReviewSummaries(newReviewSummaries: [CourseReviewSummary], ids reviewIds: [Int], courses: [Course]) {
        let reviews = Sorter.sort(newReviewSummaries, byIds: reviewIds)
        if reviews.count == 0 {
            CoreDataHelper.instance.save()
            return
        }

        var reviewCnt = 0
        for i in 0 ..< courses.count {
            if courses[i].reviewSummaryId == reviews[reviewCnt].id {
                courses[i].reviewSummary = reviews[reviewCnt]
                reviewCnt += 1
            }
            if reviewCnt == reviews.count {
                break
            }
        }
        CoreDataHelper.instance.save()
    }

    var emptyDatasetState: EmptyDatasetState = .empty {
        didSet {
            UIThread.performUI {
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

    var courses: [Course] = [] {
        didSet {
            didSetCourses()
        }
    }
    var meta: Meta?

    var isLoadingMore = false
    var isRefreshing = false {
        didSet {
            self.refreshingChangedTo(isRefreshing)
        }
    }

    func didSetCourses() {}

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

    @discardableResult func updateReviewSummaries(forCourses newCourses: [Course], completion: @escaping () -> Void) -> Request? {
        var reviewIds: [Int] = []
        var reviews: [CourseReviewSummary] = []
        for course in newCourses {
            if let reviewId = course.reviewSummaryId {
                reviewIds += [reviewId]
            }
            if let review = course.reviewSummary {
                reviews += [review]
            }
        }
        return ApiDataDownloader.courseReviewSummaries.retrieve(ids: reviewIds, existing: reviews, refreshMode: .update, success: {
            [weak self]
            newReviews -> Void in

            self?.matchReviewSummaries(newReviewSummaries: newReviews, ids: reviewIds, courses: newCourses)
            completion()
            }, error: {
                _ in
                completion()
                print("Error while dowloading progresses")
        })
    }

    @discardableResult func updateProgresses(forCourses newCourses: [Course], completion: @escaping () -> Void) -> Request? {
        var progressIds: [String] = []
        var progresses: [Progress] = []
        for course in newCourses {
            if let progressId = course.progressId {
                progressIds += [progressId]
            }
            if let progress = course.progress {
                progresses += [progress]
            }
        }

        return ApiDataDownloader.progresses.retrieve(ids: progressIds, existing: progresses, refreshMode: .update, success: {
            [weak self]
            newProgresses -> Void in

            self?.matchProgresses(newProgresses: newProgresses, ids: progressIds, courses: newCourses)
            completion()

        }, error: {
            _ in
            completion()
            print("Error while dowloading progresses")
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
            _ = ApiDataDownloader.courses.retrieveDisplayedIds(featured: self.loadFeatured, enrolled: self.loadEnrolled, isPublic: self.loadPublic, order: self.loadOrder, page: self.currentPage + 1, success: {
                idsImmutable, meta -> Void in
                var ids = idsImmutable
                _ = ApiDataDownloader.courses.retrieve(ids: ids, existing: Course.getAllCourses(), refreshMode: .update, success: {
                    [weak self]
                    (newCoursesImmutable) -> Void in
                    guard let s = self else { return }
                    var newCourses = newCoursesImmutable
                    newCourses = s.getNonExistingCourses(newCourses)
                    ids = ids.flatMap {
                        id in
                        newCourses.index {$0.id == id} != nil ? id : nil
                    }

                    let coursesCompletion = {
                        DispatchQueue.main.async {
                            s.tableView.reloadData()
                        }
                    }

                    s.courses += Sorter.sort(newCourses, byIds: ids)
                    s.meta = meta
                    s.currentPage += 1
                    s.tabIds += ids
                    s.tableView.reloadData()

                    s.updateProgresses(forCourses: newCourses, completion: coursesCompletion)
                    s.updateReviewSummaries(forCourses: newCourses, completion: coursesCompletion)
                    s.isLoadingMore = false
                    s.failedLoadingMore = false
                    }, error: {
                        [weak self]
                        _ in
                        print("failed downloading courses data in Next")
                        self?.handleLoadMoreError()
                })

                }, failure: {
                    [weak self]
                    _ in
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

        if segue.identifier == "showProfile" {
            let dvc = segue.destination
            dvc.hidesBottomBarWhenPushed = true
        }
    }

    func getNonExistingCourses(_ newCourses: [Course]) -> [Course] {
        return newCourses.flatMap {
            newCourse in
            if let _ = courses.index(where: {$0 == newCourse}) {
                return nil
            } else {
                return newCourse
            }
        }
    }

    func continueLearning(course: Course) {

        guard
        let sectionsVC = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as? SectionsViewController,
        let unitsVC = ControllerHelper.instantiateViewController(identifier: "UnitsViewController") as? UnitsViewController,
        let lessonVC = ControllerHelper.instantiateViewController(identifier: "LessonViewController") as? LessonViewController else {
            return
        }

        sectionsVC.course = course
        sectionsVC.hidesBottomBarWhenPushed = true
        unitsVC.unitId = course.lastStep?.unitId

        lessonVC.initIds = (stepId: course.lastStep?.stepId, unitId: course.lastStep?.unitId)

        //For prev-next step buttons navigation
        lessonVC.sectionNavigationDelegate = unitsVC

        if course.lastStep?.unitId != nil && course.lastStep?.stepId != nil {
            navigationController?.pushViewController(sectionsVC, animated: false)
            navigationController?.pushViewController(unitsVC, animated: false)
            navigationController?.pushViewController(lessonVC, animated: true)
            AnalyticsReporter.reportEvent(AnalyticsEvents.Continue.stepOpened, parameters: nil)
        } else {
            navigationController?.pushViewController(sectionsVC, animated: true)
            AnalyticsReporter.reportEvent(AnalyticsEvents.Continue.sectionsOpened, parameters: nil)
        }

    }

    func actionPressed(course: Course) {
        if course.enrolled {
            continuePressed(course: course)
        } else {
            unenrolledPressed(course: course)
        }
    }

    func unenrolledPressed(course: Course) {
        self.performSegue(withIdentifier: "showCourse", sender: course)
    }

    func continuePressed(course: Course) {
        SVProgressHUD.show()

        guard let lastStepId = course.lastStepId else {
            return
        }

        let errorBlock = {
            [weak self] in
            DispatchQueue.main.async {
                SVProgressHUD.showSuccess(withStatus: "")
                self?.continueLearning(course: course)
            }
        }

        let successBlock = {
            [weak self] in
            DispatchQueue.main.async {
                SVProgressHUD.showSuccess(withStatus: "")
                self?.continueLearning(course: course)
            }
        }

        print("LastStep stepId before refresh: \(String(describing: course.lastStep?.stepId))")
        _ = ApiDataDownloader.lastSteps.retrieve(ids: [lastStepId], updatingLastSteps: course.lastStep != nil ? [course.lastStep!] : [], success: {
            newLastSteps -> Void in

            guard let newLastStep = newLastSteps.first,
                (newLastSteps.count > 0 && newLastSteps.count < 2) else {
                errorBlock()
                return
            }

            print("new stepId \(String(describing: newLastStep.stepId))")

            course.lastStep = newLastStep
            CoreDataHelper.instance.save()
            successBlock()

        }, error: {
            _ in
            print("Error while downloading last step")
            errorBlock()
        })
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        let locationInTableView = tableView.convert(location, from: self.view)

        guard let indexPath = tableView.indexPathForRow(at: locationInTableView) else {
            return nil
        }

        guard indexPath.row < courses.count else {
            return nil
        }

        guard let cell = tableView.cellForRow(at: indexPath) as? CourseTableViewCell else {
            return nil
        }

        previewingContext.sourceRect = cell.frame

        if !courses[indexPath.row].enrolled {
            guard let courseVC = ControllerHelper.instantiateViewController(identifier: "CoursePreviewViewController") as? CoursePreviewViewController else {
                return nil
            }
            AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Course.peeked)
            courseVC.course = courses[indexPath.row]
            courseVC.parentShareBlock = {
                [weak self]
                shareVC in
                AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Course.shared)
                shareVC.popoverPresentationController?.sourceView = cell
                self?.present(shareVC, animated: true, completion: nil)
            }
            courseVC.hidesBottomBarWhenPushed = true
            return courseVC
        } else {
            guard let courseVC = ControllerHelper.instantiateViewController(identifier: "SectionsViewController") as? SectionsViewController else {
                return nil
            }
            AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Course.peeked)
            courseVC.course = courses[indexPath.row]
            courseVC.parentShareBlock = {
                [weak self]
                shareVC in
                AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Course.shared)
                shareVC.popoverPresentationController?.sourceView = cell
                self?.present(shareVC, animated: true, completion: nil)
            }
            courseVC.hidesBottomBarWhenPushed = true
            return courseVC
        }
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
        AnalyticsReporter.reportEvent(AnalyticsEvents.PeekNPop.Course.popped)
    }
}

extension CoursesViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == courses.count && needRefresh() {
            return 60
        } else {
            return 100
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == courses.count && needRefresh() {
            return 60
        } else {
            return UITableViewAutomaticDimension
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

        guard indexPath.row < courses.count else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseWidgetTableViewCell", for: indexPath) as! CourseWidgetTableViewCell

        let course = courses[(indexPath as NSIndexPath).row]
        cell.initWithCourse(course, action: {
            [weak self] in
            self?.actionPressed(course: course)
        })

        return cell
    }
}
