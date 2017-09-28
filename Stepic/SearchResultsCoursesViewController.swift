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

enum SearchResultsState: String {
    case suggestions = "suggestions", courses = "courses"
}

class SearchResultsCoursesViewController: CoursesViewController {

    var parentVC: UIViewController?

    var updateSearchBarBlock: ((String) -> Void)?
    var hideKeyboardBlock: (() -> Void)?

    lazy var suggestionsVC: SearchQueriesViewController = {
        let vc = SearchQueriesViewController()
        vc.delegate = self
        self.addChildViewController(vc)
        self.view.addSubview(vc.view)
        vc.view.align(toView: self.view)
        vc.view.isHidden = true
        vc.hideKeyboardBlock = self.hideKeyboardBlock
        return vc
    }()

    var state = SearchResultsState.suggestions

    var query: String = "" {
        didSet {
            switch state {
            case .suggestions:
                if query != "" {
                    suggestionsVC.query = query
                    suggestionsVC.view.isHidden = false
                    break
                }
            case .courses:
                suggestionsVC.view.isHidden = true
                self.isLoadingMore = false
                self.currentRequest?.cancel()
                refreshCourses()
                break
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

    lazy var activityView: UIView = self.initActivityView()

    func initActivityView() -> UIView {
        let v = UIView()
        let ai = UIActivityIndicatorView()
        ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        ai.constrainWidth("50", height: "50")
        ai.color = UIColor.mainDark
        v.backgroundColor = UIColor.white
        v.addSubview(ai)
        ai.alignCenter(withView: v)
        ai.startAnimating()
        self.view.insertSubview(v, aboveSubview: tableView)
        v.align(toView: self.view)
        v.isHidden = false
        return v
    }

    var doesPresentActivityIndicatorView: Bool = false {
        didSet {
            if doesPresentActivityIndicatorView {
                print("present activity indicator view")
                UIThread.performUI {self.activityView.isHidden = false}
            } else {
                print("dismiss activity indicator view")
                UIThread.performUI {self.activityView.isHidden = true}
            }
        }
    }

    override func viewDidLoad() {
        refreshEnabled = false

        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self

        super.viewDidLoad()
        // Do any additional setup after loading the view.        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        countTopOffset()
    }

    var viewTopHeight: CGFloat?

    func countTopOffset() {
        guard let navigationHeight = parentVC?.navigationController?.navigationBar.bounds.height else {
            return
        }

        let topHeight = UIApplication.shared.statusBarFrame.height + navigationHeight

        if let currentHeight = viewTopHeight {
            let topOffset = currentHeight - topHeight
            if topOffset != 0 {
                self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y - topOffset, width: self.view.frame.width, height: self.view.frame.height + topOffset)
            }
        }
        viewTopHeight = topHeight
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        countTopOffset()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewTopHeight = nil
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    var currentRequest: Request?

    let cancelErrorCode: Int = -999

    override func refreshCourses() {
        isRefreshing = true
        performRequest({
            [weak self]
            () -> Void in
            if let s = self {
                s.currentRequest = ApiDataDownloader.search.search(query: s.query, type: "course", page: 1, success: {
                    searchResults, meta -> Void in
                    let ids = searchResults.flatMap({return $0.courseId})

                    s.currentRequest = ApiDataDownloader.courses.retrieve(ids: ids, existing: Course.getAllCourses(), refreshMode: .update, success: {
                        newCourses -> Void in

                        let coursesCompletion = {
                            s.courses = Sorter.sort(newCourses, byIds: ids)
                            s.meta = meta
                            s.currentPage = 1
                            DispatchQueue.main.async {
                                s.refreshControl?.endRefreshing()
                                s.tableView.reloadData()
                            }
                        }

                        s.currentRequest = s.updateProgresses(forCourses: newCourses, completion: coursesCompletion)

                        s.isRefreshing = false
                        }, error: {
                            error -> Void in
                            print("failed downloading courses data in refresh")
                            if error != .cancelled {
                                s.handleRefreshError()
                            }
                    })

                    }, error: {
                        error -> Void in
                        print("failed refreshing course ids in refresh")
                        if error.code != s.cancelErrorCode {
                            s.handleRefreshError()
                        }
                })
            }
            }, error: {
                [weak self]
                error in
                guard let s = self else { return }
                if error == PerformRequestError.noAccessToRefreshToken {
                    AuthInfo.shared.token = nil
                    RoutingManager.auth.routeFrom(controller: s, success: {
                        [weak self] in
                        self?.refreshCourses()
                        }, cancel: nil)
                }
                self?.handleRefreshError()
        })
    }

    override func loadNextPage() {
        if isRefreshing || isLoadingMore {
            return
        }

        isLoadingMore = true
        performRequest({
            [weak self]
            () -> Void in
            guard let s = self else {
                return
            }
            _ = ApiDataDownloader.search.search(query: s.query, type: "course", page: s.currentPage + 1, success: {
                [weak self]
                (searchResults, meta) -> Void in

                guard let s = self else {
                    return
                }

                let ids = searchResults.flatMap({return $0.courseId})
                _ = ApiDataDownloader.courses.retrieve(ids: ids, existing: Course.getAllCourses(), refreshMode: .update, success: {
                    [weak self]
                    (newCourses) -> Void in

                    guard let s = self else {
                        return
                    }

                    if !s.isLoadingMore {
                        return
                    }

                    let coursesCompletion = {
                        s.currentPage += 1
                        s.courses += Sorter.sort(newCourses, byIds: ids)
                        s.meta = meta
                        //                        self.refreshControl.endRefreshing()
                        UIThread.performUI {s.tableView.reloadData()}
                    }

                    s.updateProgresses(forCourses: newCourses, completion: coursesCompletion)

                    s.isLoadingMore = false
                    s.failedLoadingMore = false
                    }, error: {
                        error -> Void in
                        print("failed downloading courses data in Next")
                        if error != .cancelled {
                            s.handleLoadMoreError()
                        }
                })

                }, error: {
                    error -> Void in
                    print("failed refreshing course ids in Next")
                    if error.code != s.cancelErrorCode {
                        s.handleLoadMoreError()
                    }
            })
        }, error: {
            [weak self]
            error in
            guard let s = self else { return }
            if error == PerformRequestError.noAccessToRefreshToken {
                AuthInfo.shared.token = nil
                RoutingManager.auth.routeFrom(controller: s, success: {
                    [weak self] in
                    self?.refreshCourses()
                    }, cancel: nil)
            }
            self?.handleLoadMoreError()
        })
    }

    override func handleRefreshError() {
        self.isRefreshing = false
        courses = []
        UIThread.performUI { self.tableView.reloadData() }
        if let vc = parentVC {
            UIThread.performUI { Messages.sharedManager.showConnectionErrorMessage(inController: vc.navigationController!) }
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
        hideKeyboardBlock?()
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

    func backgroundColorForEmptyDataSet(_ scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }

    func verticalOffsetForEmptyDataSet(_ scrollView: UIScrollView!) -> CGFloat {
        return 0
    }
}

extension SearchResultsCoursesViewController {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return false
    }

    func emptyDataSetDidTapView(_ scrollView: UIScrollView!) {
        hideKeyboardBlock?()
    }
}

extension SearchResultsCoursesViewController: SearchQueriesViewControllerDelegate {
    func didSelectSuggestion(suggestion: String, position: Int) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Search.selected, parameters: ["query": self.query.lowercased(), "position": position, "suggestion": suggestion])
        self.state = .courses
        updateSearchBarBlock?(suggestion)
        self.query = suggestion
    }
}
