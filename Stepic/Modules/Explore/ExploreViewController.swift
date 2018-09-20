//
//  ExploreExploreViewController.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ExploreViewControllerProtocol: class {
    func displayContent(viewModel: Explore.LoadContent.ViewModel)
}

final class ExploreViewController: UIViewController {
    let interactor: ExploreInteractorProtocol
    private var state: Explore.ViewControllerState

    lazy var exploreView = self.view as? ExploreView

    init(
        interactor: ExploreInteractorProtocol,
        initialState: Explore.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = ExploreView(frame: UIScreen.main.bounds)

        // Add content switch module at start
        // cause it does not depend on content
        let contentLanguageSwitchAssembly = ContentLanguageSwitchAssembly()
        let clViewController = contentLanguageSwitchAssembly.makeModule()
        self.addChildViewController(clViewController)
        view.addBlockView(clViewController.view)

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactor.loadContent(request: .init())
    }

    // MARK: Private methods

    private func removeLanguageDependentSubmodules() {

    }

    private func initLanguageDependentSubmodules(contentLanguage: ContentLanguage) {
        let tagsAssembly = TagsAssembly(contentLanguage: contentLanguage)
        let tagsViewController = tagsAssembly.makeModule()
        self.addChildViewController(tagsViewController)
        self.exploreView?.addBlockView(tagsViewController.view)

        let collectionAssembly = CourseListsCollectionAssembly(contentLanguage: contentLanguage)
        let collectionViewController = collectionAssembly.makeModule()
        self.addChildViewController(collectionViewController)
        self.exploreView?.addBlockView(collectionViewController.view)

        let popularAssembly = CourseListAssembly(
            type: PopularCourseListType(language: contentLanguage),
            colorMode: .dark,
            presentationOrientation: .horizontal
        )
        let popularViewController = popularAssembly.makeModule()
        popularAssembly.moduleInput?.reload()
        self.addChildViewController(popularViewController)

        let container = CourseListContainerViewFactory(colorMode: .dark)
            .makeHorizontalContainerView(
                for: popularViewController.view,
                headerDescription: .init(
                    title: NSLocalizedString("Popular", comment: ""),
                    summary: nil
                )
            )
        container.onShowAllButtonClick = { }
        self.exploreView?.addBlockView(container)
    }
}

extension ExploreViewController: ExploreViewControllerProtocol {
    func displayContent(viewModel: Explore.LoadContent.ViewModel) {
        switch viewModel.state {
        case .normal(let language):
            //self.removeLanguageDependentSubmodules()
            self.initLanguageDependentSubmodules(contentLanguage: language)
        case .loading:
            break
        }

    }
}
