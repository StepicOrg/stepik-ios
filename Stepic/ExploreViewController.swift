//
//  ExploreViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import SnapKit

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
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
        //Initialized in reverse order to be inserted in correct way
        presenter?.setupWidgets()
    }

    private func setupStackView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)

        scrollView.snp.makeConstraints { make -> Void in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(searchBar.snp.bottom)
            make.bottom.equalTo(self.view)
        }

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalTo(scrollView) }
        stackView.alignment = .fill
    }

    var blocks: [CourseListBlock] = []
    var countForID: [String: Int] = [:]
    var countUpdateBlock: [String: () -> Void] = [:]
    var removeBlockForID: [String: () -> Void] = [:]
    var listTypeUpdateBlockForID: [String: (CourseListType, Bool) -> Void] = [:]
    var onlyLocalUpdateBlockForID: [String: (Bool) -> Void] = [:]
    var titleDescriptionUpdateBlockForID: [String: (String, String?) -> Void] = [:]

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
            courseListView.snp.makeConstraints { make -> Void in
                make.leading.trailing.equalTo(self.view)
            }

            removeBlockForID[block.ID] = {
                courseListView.isHidden = true
                courseListView.removeFromSuperview()
                block.horizontalController.removeFromParentViewController()
            }
            listTypeUpdateBlockForID[block.ID] = {
                newListType, onlyLocal in
                block.onlyLocal = onlyLocal
                block.listType = newListType
                block.horizontalController.presenter?.listType = newListType
                block.horizontalController.presenter?.onlyLocal = onlyLocal
                block.horizontalController.presenter?.refresh()
            }
            onlyLocalUpdateBlockForID[block.ID] = {
                onlyLocal in
                block.onlyLocal = onlyLocal
                block.horizontalController.presenter?.onlyLocal = onlyLocal
                block.horizontalController.presenter?.refresh()
            }
            titleDescriptionUpdateBlockForID[block.ID] = {
                newTitle, newDescription in
                block.description = newDescription
                block.title = newTitle
                courseListView.titleLabel.text = newTitle
                courseListView.listDescription = newDescription
            }
        }
    }

    func updateBlock(withID ID: String, newListType: CourseListType, onlyLocal: Bool) {
        listTypeUpdateBlockForID[ID]?(newListType, onlyLocal)
    }

    func updateBlock(withID ID: String, onlyLocal: Bool) {
        onlyLocalUpdateBlockForID[ID]?(onlyLocal)
    }

    func updateBlock(withID ID: String, newTitle: String, newDescription: String?) {
        titleDescriptionUpdateBlockForID[ID]?(newTitle, newDescription)
    }

    private func removeBlocks() {
        for block in blocks {
            removeBlockForID[block.ID]?()
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

    var storiesWidgetView: UIView?

    func hideStories() {
        if let storiesWidgetView = storiesWidgetView {
            storiesWidgetView.isHidden = true
            stackView.removeArrangedSubview(storiesWidgetView)
            stackView.setNeedsLayout()
            UIView.animate(withDuration: 0.15, animations: {
                self.stackView.layoutIfNeeded()
            })
            self.storiesWidgetView = nil
        }
    }

    func setStories() {
        guard let presenter = self.presenter else {
            return
        }
        let storiesModule = StoriesAssembly(refreshDelegate: presenter).makeModule()
        addChildViewController(storiesModule)
        let widgetBackgroundView = UIView()
        widgetBackgroundView.backgroundColor = UIColor.white
        widgetBackgroundView.addSubview(storiesModule.view)
        storiesModule.view.snp.makeConstraints { make -> Void in
            make.top.equalTo(widgetBackgroundView).offset(16)
            make.bottom.equalTo(widgetBackgroundView).offset(0)
            make.height.equalTo(98)
        }
        if #available(iOS 11.0, *) {
            storiesModule.view.snp.makeConstraints { make -> Void in
                make.leading.equalTo(widgetBackgroundView.safeAreaLayoutGuide.snp.leading).offset(0)
                make.trailing.equalTo(widgetBackgroundView.safeAreaLayoutGuide.snp.trailing).offset(0)
            }
        } else {
            storiesModule.view.snp.makeConstraints { make -> Void in
                make.leading.equalTo(widgetBackgroundView).offset(0)
                make.trailing.equalTo(widgetBackgroundView).offset(0)
            }
        }
        widgetBackgroundView.isHidden = false
        stackView.insertArrangedSubview(widgetBackgroundView, at: 0)
        storiesWidgetView = widgetBackgroundView
    }

    func setLanguages(withLanguages languages: [ContentLanguage], initialLanguage: ContentLanguage, onSelected: @escaping (ContentLanguage) -> Void) {
        let languagesWidget = ContentLanguagesView(frame: CGRect.zero)
        languagesWidget.languages = languages
        languagesWidget.languageSelectedAction = onSelected
        languagesWidget.initialLanguage = initialLanguage

        let widgetBackgroundView = UIView()
        widgetBackgroundView.backgroundColor = UIColor.white
        widgetBackgroundView.addSubview(languagesWidget)
        languagesWidget.snp.makeConstraints { make -> Void in
            make.top.equalTo(widgetBackgroundView).offset(16)
            make.bottom.equalTo(widgetBackgroundView).offset(-8)
        }
        if #available(iOS 11.0, *) {
            languagesWidget.snp.makeConstraints { make -> Void in
                make.leading.equalTo(widgetBackgroundView.safeAreaLayoutGuide.snp.leading).offset(16)
                make.trailing.equalTo(widgetBackgroundView.safeAreaLayoutGuide.snp.trailing).offset(-16)
            }
        } else {
            languagesWidget.snp.makeConstraints { make -> Void in
                make.leading.equalTo(widgetBackgroundView).offset(16)
                make.trailing.equalTo(widgetBackgroundView).offset(-16)
            }
        }
        widgetBackgroundView.isHidden = false
        stackView.insertArrangedSubview(widgetBackgroundView, at: 0)

        widgetBackgroundView.snp.makeConstraints { $0.leading.trailing.equalTo(self.view) }

        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 83 / 255.0, green: 83 / 255.0, blue: 102 / 255.0, alpha: 0.3)
        widgetBackgroundView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make -> Void in
            make.leading.trailing.equalTo(widgetBackgroundView)
            make.height.equalTo(0.5)
            make.bottom.equalTo(widgetBackgroundView).offset(0.5)
        }
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

        tagsWidget.snp.makeConstraints { make -> Void in
            make.top.equalTo(widgetBackgroundView).offset(16)
            make.bottom.equalTo(widgetBackgroundView).offset(-8)
        }
        if #available(iOS 11.0, *) {
            tagsWidget.snp.makeConstraints { make -> Void in
                make.leading.equalTo(widgetBackgroundView.safeAreaLayoutGuide.snp.leading)
                make.trailing.equalTo(widgetBackgroundView.safeAreaLayoutGuide.snp.trailing)
            }
        } else {
            tagsWidget.snp.makeConstraints { make -> Void in
                make.leading.equalTo(widgetBackgroundView)
                make.trailing.equalTo(widgetBackgroundView)
            }
        }

        widgetBackgroundView.isHidden = false

        stackView.insertArrangedSubview(widgetBackgroundView, at: 0)

        widgetBackgroundView.snp.makeConstraints { make -> Void in
            make.leading.trailing.equalTo(self.view)
        }

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

        vc.view.snp.makeConstraints { make -> Void in
            make.leading.trailing.bottom.equalTo(self.view)
            make.top.equalTo(searchBar.snp.bottom)
        }
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
        placeholder.snp.makeConstraints { make -> Void in
            make.top.equalTo(v).offset(16)
            make.leading.bottom.trailing.equalTo(v)
            make.height.equalTo(100)
        }
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

        searchBar.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 800), for: .vertical)
        searchBar.snp.makeConstraints { make -> Void in
            make.height.equalTo(44)
            make.top.equalTo(self.view)
            make.leading.trailing.equalTo(self.view)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmplitudeAnalyticsEvents.Catalog.opened.send()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.willAppear()
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
        AmplitudeAnalyticsEvents.Search.started.send()
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
