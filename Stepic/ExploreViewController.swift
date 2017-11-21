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
        (navigationController as? StyledNavigationViewController)?.customShadowView?.alpha = 0
        presenter?.refresh()
        self.title = NSLocalizedString("Catalog", comment: "")
        #if swift(>=3.2)
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
            }
        #endif
        presenter?.initLanguagesWidget()
        presenter?.initTagsWidget()
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

    var tagsWidget: CourseTagsView?

    func setTags(withTags tags: [CourseTag], language: ContentLanguage, onSelected: @escaping (CourseTag) -> Void) {
        tagsWidget = CourseTagsView(frame: CGRect.zero)
        guard let tagsWidget = tagsWidget else {
            return
        }
        let widgetBackgroundView = UIView()
        widgetBackgroundView.backgroundColor = UIColor.white
        widgetBackgroundView.addSubview(tagsWidget)
        tagsWidget.alignTop("16", bottom: "-8", toView: widgetBackgroundView)
        tagsWidget.alignLeading("0", trailing: "0", toView: widgetBackgroundView)
        widgetBackgroundView.isHidden = false
        stackView.insertArrangedSubview(widgetBackgroundView, at: 1)
        widgetBackgroundView.alignLeading("0", trailing: "0", toView: self.view)
        tagsWidget.tags = tags
        tagsWidget.language = language
        tagsWidget.tagSelectedAction = onSelected
    }

    func updateTagsLanguage(language: ContentLanguage) {
        tagsWidget?.language = language
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

    func hideKeyboard() {
        self.hideKeyboardIfNeeded()
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

    lazy var searchBar: CustomSearchBar = {
        CustomSearchBar()
    }()

    func hideKeyboardIfNeeded() {
        searchBar.textField.resignFirstResponder()
    }

    lazy var emptyPlaceholder: UIView = {
        let v = UIView()
        let placeholder = CourseListEmptyPlaceholder(frame: CGRect.zero)
        v.addSubview(placeholder)
        placeholder.alignTop("16", leading: "0", bottom: "0", trailing: "0", toView: v)
        placeholder.constrainHeight("100")
        placeholder.isHidden = false
        placeholder.text = NSLocalizedString("CatalogPlaceholderError", comment: "")
        placeholder.onTap = {
            [weak self] in
            self?.presenter?.refresh()
        }
        v.isHidden = true
        return v
    }()

    func setConnectionProblemsPlaceholder(hidden: Bool) {
        if !hidden {
            stackView.addArrangedSubview(emptyPlaceholder)
            emptyPlaceholder.isHidden = false
        } else {
            emptyPlaceholder.isHidden = true
            stackView.removeArrangedSubview(emptyPlaceholder)
        }
    }

    private func setupSearch() {
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
    }

    func cancelPressed(in searchBar: CustomSearchBar) {
        searchBar.resignFirstResponder()
        self.presenter?.searchCancelled()
        AnalyticsReporter.reportEvent(AnalyticsEvents.Search.cancelled)
    }

    func startedEditing(in searchBar: CustomSearchBar) {
        self.presenter?.searchStarted()
    }

    func returnPressed(in searchBar: CustomSearchBar) {
        self.presenter?.search(query: searchBar.text)
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
