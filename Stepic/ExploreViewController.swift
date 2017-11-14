//
//  ExploreViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import FLKAutoLayout

class ExploreViewController: UIViewController, ExploreView {
    var presenter: ExplorePresenter?

    var scrollView: UIScrollView = UIScrollView()
    var stackView: UIStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = ExplorePresenter(view: self, courseListsAPI: CourseListsAPI(), courseListsCache: CourseListsCache())
        setupSearch()
        setupStackView()
//        setupSearchResults()
        (navigationController as? StyledNavigationViewController)?.customShadowView?.alpha = 0
        presenter?.refresh()
        self.title = NSLocalizedString("Explore", comment: "")
        #if swift(>=3.2)
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
            }
        #endif
        presenter?.initLanguagesWidget()
    }

    private func setupStackView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)

        scrollView.alignLeading("0", trailing: "0", toView: self.view)
        scrollView.constrainTopSpace(toView: searchBar, predicate: "0")
        scrollView.alignBottomEdge(withView: self.view, predicate: "0")

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        scrollView.addSubview(stackView)
        stackView.align(toView: scrollView)
        stackView.alignment = .fill
    }

    var blocks: [CourseListBlock] = []
    var countForID: [String: Int] = [:]
    var countUpdateBlock: [String: () -> Void] = [:]
    var removeBlockForId: [String: () -> Void] = [:]

    private func reload() {
        for block in blocks {
            let courseListView: HorizontalCoursesView = HorizontalCoursesView(frame: CGRect.zero)
            self.addChildViewController(block.horizontalController)
            courseListView.setup(block: block)
            countUpdateBlock[block.ID] = {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                courseListView.courseCount = strongSelf.countForID[block.ID] ?? 0
            }
            if let count = countForID[block.ID] {
                courseListView.courseCount = count
            }
            stackView.addArrangedSubview(courseListView)
            courseListView.alignLeading("0", trailing: "0", toView: self.view)
            removeBlockForId[block.ID] = {
                courseListView.isHidden = true
                courseListView.removeFromSuperview()
                block.horizontalController.removeFromParentViewController()
            }
        }
    }

    private func removeBlocks() {
        for block in blocks {
            removeBlockForId[block.ID]?()
        }
    }

    func presentBlocks(blocks: [CourseListBlock]) {
        removeBlocks()
        self.blocks = blocks
        reload()
    }

    func getNavigation() -> UINavigationController? {
        return self.navigationController
    }

    func setLanguages(withLanguages languages: [ContentLanguage], initialLanguage: ContentLanguage, onSelected: @escaping (ContentLanguage) -> Void) {
        let languagesWidget = ContentLanguagesView(frame: CGRect.zero)
        languagesWidget.languages = languages
        languagesWidget.languageSelectedAction = onSelected
        languagesWidget.initialLanguage = initialLanguage

        let widgetBackgroundView = UIView()
        widgetBackgroundView.backgroundColor = UIColor.white
        widgetBackgroundView.addSubview(languagesWidget)
        languagesWidget.alignTop("16", bottom: "-8", toView: widgetBackgroundView)
        languagesWidget.alignLeading("16", trailing: "-16", toView: widgetBackgroundView)
        widgetBackgroundView.isHidden = false
        stackView.insertArrangedSubview(widgetBackgroundView, at: 0)
        widgetBackgroundView.alignLeading("0", trailing: "0", toView: self.view)
    }

    func updateCourseCount(to count: Int, forBlockWithID ID: String) {
        countForID[ID] = count
        countUpdateBlock[ID]?()
    }

    func show(vc: UIViewController) {
        self.show(vc, sender: nil)
    }

    func updateSearchQuery(to query: String) {
        searchBar.text = query
    }

    var searchController: UIViewController?

    func setSearch(vc: UIViewController) {
        if let searchController = searchController {
            searchController.removeFromParentViewController()
            searchController.view.removeFromSuperview()
        }
        searchController = vc
        self.addChildViewController(vc)
        self.view.addSubview(vc.view)
        vc.view.alignLeading("0", trailing: "0", toView: self.view)
        vc.view.constrainTopSpace(toView: searchBar, predicate: "0")
        vc.view.alignBottomEdge(withView: self.view, predicate: "0")
    }

    func setSearch(hidden: Bool) {
        searchController?.view.isHidden = hidden
    }

    // Bad code here
//    var searchResultsVC: SearchResultsCoursesViewController!
    lazy var searchBar: CustomSearchBar = {
        CustomSearchBar()
    }()

//    lazy var darkOverlayView: UIView = {
//        let v = UIView()
//        v.backgroundColor = UIColor.black
//        let tapG = UITapGestureRecognizer(target: self, action: #selector(ExploreViewController.didTapBlackView))
//        v.addGestureRecognizer(tapG)
//        return v
//    }()

    func hideKeyboardIfNeeded() {
        searchBar.resignFirstResponder()
    }

    private func setupSearch() {
//        searchResultsVC = ControllerHelper.instantiateViewController(identifier: "SearchResultsCoursesViewController") as! SearchResultsCoursesViewController
//        searchResultsVC.parentVC = self
//        searchResultsVC.hideKeyboardBlock = {
//            [weak self] in
//            self?.hideKeyboardIfNeeded()
//        }
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
    }
//
//    private func setupSearchResults() {
//        self.view.addSubview(darkOverlayView)
//        darkOverlayView.alignLeading("0", trailing: "0", toView: self.view)
//        darkOverlayView.constrainTopSpace(toView: searchBar, predicate: "0")
//        darkOverlayView.alignBottomEdge(withView: self.view, predicate: "0")
//        darkOverlayView.isHidden = true
//
//        self.addChildViewController(searchResultsVC)
//        self.view.addSubview(searchResultsVC.view)
//        searchResultsVC.view.alignLeading("0", trailing: "0", toView: self.view)
//        searchResultsVC.view.constrainTopSpace(toView: searchBar, predicate: "0")
//        searchResultsVC.view.alignBottomEdge(withView: self.view, predicate: "0")
//        searchResultsVC.view.isHidden = true
//    }
//
//    var isDisplayingFromSuggestions: Bool = false
//
//    func didTapBlackView() {
//        searchBar.cancel()
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if navigationController?.delegate === self {
            navigationController?.delegate = nil
        }
    }
}

extension ExploreViewController : CustomSearchBarDelegate {
    func changedText(in searchBar: CustomSearchBar, to text: String) {
        self.presenter?.queryChanged(to: text)
//        guard let results = searchResultsVC else {
//            return
//        }
//        guard !isDisplayingFromSuggestions else {
//            isDisplayingFromSuggestions = false
//            return
//        }
//        guard text != "" else {
//            results.view.isHidden = true
//            return
//        }
//        if results.view.isHidden {
//            results.view.isHidden = false
//            results.view.alpha = 0
//            UIView.animate(withDuration: 0.3, animations: {
//                results.view.alpha = 1
//            })
//        }
//        results.state = .suggestions
//        results.query = text
//        results.updateSearchBarBlock = {
//            [weak self]
//            newQuery in
//            self?.isDisplayingFromSuggestions = true
//            self?.searchBar.text = newQuery
//            self?.searchBar.becomeFirstResponder()
//        }
//        results.countTopOffset()
    }

    func cancelPressed(in searchBar: CustomSearchBar) {
        searchBar.resignFirstResponder()
        self.presenter?.searchCancelled()
//        if searchBar.text == "" {
//            UIView.animate(withDuration: 0.3, animations: {
//                [weak self] in
//                self?.darkOverlayView.alpha = 0
//                }, completion: {
//                    [weak self]
//                    _ in
//                    self?.darkOverlayView.isHidden = true
//            })
//        } else {
//            self.darkOverlayView.isHidden = true
//            UIView.animate(withDuration: 0.3, animations: {
//                [weak self] in
//                self?.searchResultsVC.view.alpha = 0
//                }, completion: {
//                    [weak self]
//                    _ in
//                    self?.searchResultsVC.view.isHidden = true
//            })
//        }
//
//        guard let results = searchResultsVC else {
//            return
//        }
//        AnalyticsReporter.reportEvent(AnalyticsEvents.Search.cancelled, parameters: ["context": results.state.rawValue])
    }

    func startedEditing(in searchBar: CustomSearchBar) {
        self.presenter?.queryChanged(to: "")
//        darkOverlayView.isHidden = false
//        darkOverlayView.alpha = 0
//        UIView.animate(withDuration: 0.3, animations: {
//            [weak self] in
//            self?.darkOverlayView.alpha = 0.4
//        })
    }

    func returnPressed(in searchBar: CustomSearchBar) {
//        guard let results = searchResultsVC else {
//            return
//        }
//        results.didSelectSuggestion(suggestion: searchBar.text, position: 0)
    }
}

extension ExploreViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideKeyboardIfNeeded()
    }
}

extension ExploreViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let navigation = self.navigationController as? StyledNavigationViewController else {
            return
        }
        navigation.animateShadowChange(for: self)
    }
}
