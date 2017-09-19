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
    lazy var searchBar: CustomSearchBar = {
        CustomSearchBar()
    }()

    lazy var darkOverlayView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black
        let tapG = UITapGestureRecognizer(target: self, action: #selector(FindCoursesViewController.didTapBlackView))
        v.addGestureRecognizer(tapG)
        return v
    }()

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
        searchBar.resignFirstResponder()
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

    override var shouldAlignTop: Bool {
        return false
    }
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
        searchBar.delegate = self
        searchBar.barTintColor = navigationController?.navigationBar.barTintColor

        searchBar.mainColor = navigationController?.navigationBar.tintColor
        searchBar.placeholder = NSLocalizedString("SearchCourses", comment: "")

        searchBar.textField.tintColor = UIColor.mainDark
        searchBar.textField.textColor = UIColor.mainText

        self.view.addSubview(searchBar)
        searchBar.constrainHeight("44")
        searchBar.setContentCompressionResistancePriority(800, for: .vertical)
        searchBar.alignTopEdge(withView: self.view, predicate: "0")
        searchBar.alignLeading("0", trailing: "0", toView: self.view)
        super.viewDidLoad()
        tableView.alignTopEdge(withView: view, predicate: "44")

        self.tableView.backgroundView = UIView()
        self.tableView.backgroundColor = UIColor.lightText

        tableView.register(UINib(nibName: "SignInCoursesTableViewCell", bundle: nil), forCellReuseIdentifier: "SignInCoursesTableViewCell")

        self.view.addSubview(darkOverlayView)
        darkOverlayView.alignLeading("0", trailing: "0", toView: self.view)
        darkOverlayView.constrainTopSpace(toView: searchBar, predicate: "0")
        darkOverlayView.alignBottomEdge(withView: self.view, predicate: "0")
        darkOverlayView.isHidden = true

        self.addChildViewController(searchResultsVC)
        self.view.addSubview(searchResultsVC.view)
        searchResultsVC.view.alignLeading("0", trailing: "0", toView: self.view)
        searchResultsVC.view.constrainTopSpace(toView: searchBar, predicate: "0")
        searchResultsVC.view.alignBottomEdge(withView: self.view, predicate: "0")
        searchResultsVC.view.isHidden = true

        (navigationController as? StyledNavigationViewController)?.customShadowView?.alpha = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableHeaderView = signInView
        navigationController?.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if navigationController?.delegate === self {
            navigationController?.delegate = nil
        }
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

    func didTapBlackView() {
        searchBar.cancel()
    }
}

extension FindCoursesViewController : CustomSearchBarDelegate {
    func changedText(in searchBar: CustomSearchBar, to text: String) {
        guard let results = searchResultsVC else {
            return
        }
        guard !isDisplayingFromSuggestions else {
            isDisplayingFromSuggestions = false
            return
        }
        guard text != "" else {
            results.view.isHidden = true
            return
        }
        if results.view.isHidden {
            results.view.isHidden = false
            results.view.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                results.view.alpha = 1
            })
        }
        results.state = .suggestions
        results.query = text
        results.updateSearchBarBlock = {
            [weak self]
            newQuery in
            self?.isDisplayingFromSuggestions = true
            self?.searchBar.text = newQuery
            self?.searchBar.becomeFirstResponder()
        }
        results.countTopOffset()
    }

    func cancelPressed(in searchBar: CustomSearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text == "" {
            UIView.animate(withDuration: 0.3, animations: {
                [weak self] in
                self?.darkOverlayView.alpha = 0
            }, completion: {
                [weak self]
                _ in
                self?.darkOverlayView.isHidden = true
            })
        } else {
            self.darkOverlayView.isHidden = true
            UIView.animate(withDuration: 0.3, animations: {
                [weak self] in
                self?.searchResultsVC.view.alpha = 0
                }, completion: {
                    [weak self]
                    _ in
                    self?.searchResultsVC.view.isHidden = true
            })
        }

        guard let results = searchResultsVC else {
            return
        }
        AnalyticsReporter.reportEvent(AnalyticsEvents.Search.cancelled, parameters: ["context": results.state.rawValue])
    }

    func startedEditing(in searchBar: CustomSearchBar) {
        darkOverlayView.isHidden = false
        darkOverlayView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            [weak self] in
            self?.darkOverlayView.alpha = 0.4
        })
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

extension FindCoursesViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let navigation = self.navigationController as? StyledNavigationViewController else {
            return
        }
        navigation.animateShadowChange(for: self)
    }
}
