//
//  ExploreExploreViewController.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import SnapKit

protocol ExploreViewControllerProtocol: BaseExploreViewControllerProtocol {
    func displayContent(viewModel: Explore.LoadContent.ViewModel)
    func displayLanguageSwitchBlock(viewModel: Explore.CheckLanguageSwitchAvailability.ViewModel)
    func displayStoriesBlock(viewModel: Explore.UpdateStoriesVisibility.ViewModel)
}

final class ExploreViewController: BaseExploreViewController {
    enum Animation {
        static let refreshDelay: TimeInterval = 1.0
    }

    static let submodulesOrder: [Explore.Submodule] = [
        .stories,
        .languageSwitch,
        .tags,
        .collection,
        .popularCourses
    ]

    private var state: Explore.ViewControllerState
    lazy var exploreInteractor = self.interactor as? ExploreInteractorProtocol

    private var searchResultsModuleInput: SearchResultsModuleInputProtocol?
    private var searchResultsController: UIViewController?
    private lazy var searchBar = ExploreSearchBar(frame: .zero)

    private var isStoriesHidden: Bool = false

    init(
        interactor: ExploreInteractorProtocol,
        initialState: Explore.ViewControllerState = .loading
    ) {
        self.state = initialState
        super.init(interactor: interactor)
        self.searchBar.searchBarDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        super.loadView()
        self.exploreView?.delegate = self
        self.navigationItem.titleView = self.searchBar
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.exploreInteractor?.loadLanguageSwitchBlock(request: .init())

        self.initSearchResults()

        self.updateState(newState: self.state)
        self.exploreInteractor?.loadContent(request: .init())
    }

    private func updateState(newState: Explore.ViewControllerState) {
        switch newState {
        case .normal(let language):
            self.removeLanguageDependentSubmodules()
            self.initLanguageDependentSubmodules(contentLanguage: language)
            self.exploreView?.endRefreshing()
        case .loading:
            break
        }
        self.state = newState
    }

    override func refreshContentAfterLanguageChange() {
        self.exploreInteractor?.loadContent(request: .init())
    }

    override func refreshContentAfterLoginAndLogout() {
        self.exploreInteractor?.loadContent(request: .init())
    }

    func initLanguageDependentSubmodules(contentLanguage: ContentLanguage) {
        // Stories
        if !isStoriesHidden {
            let storiesAssembly = StoriesAssembly(
                output: self.exploreInteractor as? StoriesOutputProtocol
            )
            let storiesViewController = storiesAssembly.makeModule()
            let storiesContainerView = ExploreStoriesContainerView(
                frame: .zero,
                contentView: storiesViewController.view
            )
            self.registerSubmodule(
                .init(
                    viewController: storiesViewController,
                    view: storiesContainerView,
                    isLanguageDependent: true,
                    type: Explore.Submodule.stories
                )
            )
        }

        // Tags
        let tagsAssembly = TagsAssembly(
            contentLanguage: contentLanguage,
            output: self.interactor as? TagsOutputProtocol
        )
        let tagsViewController = tagsAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: tagsViewController,
                view: tagsViewController.view,
                isLanguageDependent: true,
                type: Explore.Submodule.tags
            )
        )

        // Collection
        let collectionAssembly = CourseListsCollectionAssembly(
            contentLanguage: contentLanguage,
            output: self.interactor
                as? (CourseListCollectionOutputProtocol & CourseListOutputProtocol)
        )
        let collectionViewController = collectionAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: collectionViewController,
                view: collectionViewController.view,
                isLanguageDependent: true,
                type: Explore.Submodule.collection
            )
        )

        // Popular courses
        let courseListType = PopularCourseListType(language: contentLanguage)
        let popularAssembly = HorizontalCourseListAssembly(
            type: courseListType,
            colorMode: .dark,
            output: self.interactor as? CourseListOutputProtocol
        )
        let popularViewController = popularAssembly.makeModule()
        let containerView = CourseListContainerViewFactory(colorMode: .dark)
            .makeHorizontalContainerView(
                for: popularViewController.view,
                headerDescription: .init(
                    title: NSLocalizedString("Popular", comment: ""),
                    summary: nil
                )
            )
        containerView.onShowAllButtonClick = { [weak self] in
            self?.interactor.loadFullscreenCourseList(
                request: .init(presentationDescription: nil, courseListType: courseListType)
            )
        }
        self.registerSubmodule(
            .init(
                viewController: popularViewController,
                view: containerView,
                isLanguageDependent: true,
                type: Explore.Submodule.popularCourses
            )
        )

        if let moduleInput = popularAssembly.moduleInput {
            self.tryToSetOnlineState(moduleInput: moduleInput)
        }
    }

    // MARK: - Search

    private func initSearchResults() {
        // Search result controller
        let searchResultAssembly = SearchResultsAssembly(
            hideKeyboardBlock: { [weak self] in
                self?.searchBar.resignFirstResponder()
            },
            updateQueryBlock: { [weak self] newQuery in
                self?.searchBar.text = newQuery
            }
        )

        let viewController = searchResultAssembly.makeModule()
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { make -> Void in
            make.edges.equalToSuperview()
        }
        self.searchResultsModuleInput = searchResultAssembly.moduleInput
        self.searchResultsController = viewController

        self.hideSearchResults()
    }

    private func hideSearchResults() {
        self.searchResultsController?.view.isHidden = true
    }

    private func showSearchResults() {
        self.searchResultsController?.view.isHidden = false
    }
}

extension Explore.Submodule: SubmoduleType {
    var position: Int {
        guard let position = ExploreViewController.submodulesOrder.index(of: self) else {
            fatalError("Given submodule type has unknown position")
        }
        return position
    }
}

extension ExploreViewController: ExploreViewControllerProtocol {
    func displayContent(viewModel: Explore.LoadContent.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayLanguageSwitchBlock(viewModel: Explore.CheckLanguageSwitchAvailability.ViewModel) {
        if viewModel.isHidden {
            return
        }

        let contentLanguageSwitchAssembly = ContentLanguageSwitchAssembly()
        let viewController = contentLanguageSwitchAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: viewController,
                view: viewController.view,
                isLanguageDependent: false,
                type: Explore.Submodule.languageSwitch
            )
        )
    }

    func displayStoriesBlock(viewModel: Explore.UpdateStoriesVisibility.ViewModel) {
        self.isStoriesHidden = true
        if let storiesBlock = self.getSubmodule(type: Explore.Submodule.stories) {
            self.removeSubmodule(storiesBlock)
        }
    }
}

extension ExploreViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.showSearchResults()
        // Strange hack to hide search results (courses)
        self.searchResultsModuleInput?.queryChanged(to: "")
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.hideSearchResults()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchResultsModuleInput?.queryChanged(to: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // FIXME: should be incapsulated
        if let text = searchBar.text, !text.isEmpty {
            self.searchResultsModuleInput?.search(query: text)
        } else {
            self.searchResultsModuleInput?.queryChanged(to: "")
        }
    }
}

extension ExploreViewController: BaseExploreViewDelegate {
    func refreshControlDidRefresh() {
        // Small delay for pretty refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.refreshDelay) { [weak self] in
            self?.exploreInteractor?.loadContent(request: .init())
        }
    }
}
