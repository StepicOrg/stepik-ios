//
//  FindCoursesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class FindCoursesViewController: CoursesViewController {

    var searchResultsVC: SearchResultsCoursesViewController!
    var searchController: UISearchController!

    var filteredCourses = [Course]()

    override var tabIds: [Int] {
        get {
            return TabsInfo.allCoursesIds
        }

        set(value) {
            TabsInfo.allCoursesIds = value
        }
    }

    func hideKeyboardIfNeeded() {
        self.searchController.searchBar.resignFirstResponder()
    }

    override func refreshBegan() {
        emptyDatasetState = .refreshing
    }

    override func didSetCourses() {
        DispatchQueue.main.async {
            [weak self] in
            self?.tableView.tableHeaderView = self?.signInView
        }
    }

    var topConstraint: NSLayoutConstraint?

    override func viewDidLoad() {

        loadEnrolled = nil
        loadFeatured = nil
        loadPublic = true
        loadOrder = "-activity"

        searchResultsVC = ControllerHelper.instantiateViewController(identifier: "SearchResultsCoursesViewController") as! SearchResultsCoursesViewController
        searchResultsVC.parentVC = self
        searchResultsVC.hideKeyboardBlock = {
            [weak self] in
            self?.hideKeyboardIfNeeded()
        }
        searchController = UISearchController(searchResultsController: searchResultsVC)

        searchController.searchBar.searchBarStyle = UISearchBarStyle.default
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.barTintColor = navigationController?.navigationBar.barTintColor
        searchController.searchBar.tintColor = navigationController?.navigationBar.tintColor

        for s in searchController.searchBar.subviews[0].subviews {
            if let textField = s as? UITextField {
                textField.tintColor = UIColor.mainDarkColor
                textField.textColor = UIColor.mainTextColor
                textField.setRoundedCorners(cornerRadius: 8.0, borderWidth: 0.5, borderColor: UIColor.lightGray)
            }
        }

        definesPresentationContext = true
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = true
        } else {
            searchController.dimsBackgroundDuringPresentation = true
        }

        searchController.searchBar.scopeButtonTitles = []

        super.viewDidLoad()

        self.tableView.backgroundView = UIView()
        self.tableView.backgroundColor = UIColor.lightText

        self.navigationItem.titleView = self.searchController.searchBar
        tableView.register(UINib(nibName: "SignInCoursesTableViewCell", bundle: nil), forCellReuseIdentifier: "SignInCoursesTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableHeaderView = signInView
        searchController.searchBar.sizeToFit()
        searchController.searchBar.layoutSubviews()
        navigationController?.navigationBar.layoutSubviews()
        self.navigationController?.delegate = self
    }

    fileprivate var signInView: UIView? {
        guard !AuthInfo.shared.isAuthorized && courses.count > 0 else {
            return nil
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SignInCoursesTableViewCell") as? SignInCoursesTableViewCell else {
            return nil
        }

        cell.signInPressedAction = {
            [weak self] in
            guard let vc = ControllerHelper.getAuthController() as? AuthNavigationViewController else {
                return
            }
            vc.success = {
                [weak self] in
                DispatchQueue.main.async {
                    self?.refreshCourses()
                }
            }
            self?.present(vc, animated: true, completion: nil)
        }
        return cell
    }

    var isDisplayingFromSuggestions: Bool = false
    
    func layoutBarAfterDelay() {
        delay(0.1) {
            [weak self] in
            self?.navigationController?.navigationBar.layoutSubviews()
        }

    }
}

extension FindCoursesViewController : UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        //This is used to prevent strange bug in search bar width layout
        delay(0.1) {
            [weak self] in
            self?.navigationController?.navigationBar.layoutSubviews()
        }
    }
}

extension FindCoursesViewController : UISearchBarDelegate {
}

extension FindCoursesViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard !isDisplayingFromSuggestions else {
            isDisplayingFromSuggestions = false
            return
        }
        let results = searchController.searchResultsController as? SearchResultsCoursesViewController
        results?.state = .suggestions
        results?.query = searchController.searchBar.text!
        results?.updateSearchBarBlock = {
            [weak self]
            newQuery in
            self?.isDisplayingFromSuggestions = true
            self?.searchController.searchBar.text = newQuery
        }
        results?.countTopOffset()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let results = searchController.searchResultsController as? SearchResultsCoursesViewController else {
            return
        }
        AnalyticsReporter.reportEvent(AnalyticsEvents.Search.cancelled, parameters: ["context": results.state.rawValue])
    }
}

extension FindCoursesViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideKeyboardIfNeeded()
    }
}

extension FindCoursesViewController {

    func imageForEmptyDataSet(_ scrollView: UIScrollView!) -> UIImage! {
        switch emptyDatasetState {
        case .empty:
            return Images.emptyCoursesPlaceholder
        case .connectionError:
            return Images.noWifiImage.size250x250
        case .refreshing:
            return Images.emptyCoursesPlaceholder

        }
    }

    func titleForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString! {
        var text: String = ""
        switch emptyDatasetState {
        case .empty:
            text = NSLocalizedString("EmptyFindCoursesTitle", comment: "")
            break
        case .connectionError:
            text = NSLocalizedString("ConnectionErrorTitle", comment: "")
            break
        case .refreshing:
            text = NSLocalizedString("Refreshing", comment: "")
            break
        }

        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0),
            NSForegroundColorAttributeName: UIColor.darkGray]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func descriptionForEmptyDataSet(_ scrollView: UIScrollView!) -> NSAttributedString! {
        var text: String = ""

        switch emptyDatasetState {
        case .empty:
            text = NSLocalizedString("EmptyFindCoursesDescription", comment: "")
            break
        case .connectionError:
            text = NSLocalizedString("ConnectionErrorPullToRefresh", comment: "")
            break
        case .refreshing:
            text = NSLocalizedString("RefreshingDescription", comment: "")
            break

        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center

        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0),
            NSForegroundColorAttributeName: UIColor.lightGray,
            NSParagraphStyleAttributeName: paragraph]

        return NSAttributedString(string: text, attributes: attributes)
    }

    func backgroundColorForEmptyDataSet(_ scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }

    func verticalOffsetForEmptyDataSet(_ scrollView: UIScrollView!) -> CGFloat {
        //        print("offset -> \((self.navigationController?.navigationBar.bounds.height) ?? 0 + UIApplication.sharedApplication().statusBarFrame.height)")
        return 44
    }
}

extension FindCoursesViewController {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}

extension FindCoursesViewController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard self.navigationController is StyledNavigationViewController else {
            return
        }
        guard viewController is FindCoursesViewController else {
            return
        }
        guard let coordinator = navigationController.topViewController?.transitionCoordinator else {
            return
        }
        self.searchController.searchBar.isHidden = true
        coordinator.animate(alongsideTransition: nil, completion: {
            [weak self]
            _ in
            self?.searchController.searchBar.isHidden = false
            self?.searchController.searchBar.alpha = 0.0
            UIView.animate(withDuration: 0.1, animations: {
                self?.searchController.searchBar.alpha = 1.0
            })
        })
    }
}
