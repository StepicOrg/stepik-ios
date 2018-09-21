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
    private var submodules: [Submodule] = []

    lazy var exploreView = self.view as? ExploreView

    init(
        interactor: ExploreInteractorProtocol,
        initialState: Explore.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
        self.registerForNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = ExploreView(frame: UIScreen.main.bounds)
        self.view = view

        // Add content switch module at start
        // cause it does not depend on content
        let contentLanguageSwitchAssembly = ContentLanguageSwitchAssembly()
        let viewController = contentLanguageSwitchAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: viewController,
                view: viewController.view,
                isLanguageDependent: false
            )
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactor.loadContent(request: .init())
    }

    // MARK: Private methods

    private func registerSubmodule(_ submodule: Submodule) {
        self.submodules.append(submodule)
        self.addChildViewController(submodule.viewController)

        if let view = submodule.view {
            self.exploreView?.addBlockView(view)
        }
    }

    private func removeLanguageDependentSubmodules() {
        for submodule in self.submodules where submodule.isLanguageDependent {
            if let view = submodule.view {
                self.exploreView?.removeBlockView(view)
            }
            submodule.viewController.removeFromParentViewController()
        }
        self.submodules = self.submodules.filter { !$0.isLanguageDependent }
    }

    private func initLanguageDependentSubmodules(contentLanguage: ContentLanguage) {
        // Tags
        let tagsAssembly = TagsAssembly(contentLanguage: contentLanguage)
        let tagsViewController = tagsAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: tagsViewController,
                view: tagsViewController.view,
                isLanguageDependent: true
            )
        )

        // Collection
        let collectionAssembly = CourseListsCollectionAssembly(contentLanguage: contentLanguage)
        let collectionViewController = collectionAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: collectionViewController,
                view: collectionViewController.view,
                isLanguageDependent: true
            )
        )

        // Popular courses
        let popularAssembly = CourseListAssembly(
            type: PopularCourseListType(language: contentLanguage),
            colorMode: .dark,
            presentationOrientation: .horizontal
        )
        let popularViewController = popularAssembly.makeModule()
        popularAssembly.moduleInput?.reload()
        let containerView = CourseListContainerViewFactory(colorMode: .dark)
            .makeHorizontalContainerView(
                for: popularViewController.view,
                headerDescription: .init(
                    title: NSLocalizedString("Popular", comment: ""),
                    summary: nil
                )
            )
        containerView.onShowAllButtonClick = { }
        self.registerSubmodule(
            .init(
                viewController: popularViewController,
                view: popularViewController.view,
                isLanguageDependent: true
            )
        )
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            forName: .contentLanguageDidChange,
            object: nil,
            queue: nil
        ) { _ in
            self.interactor.loadContent(request: .init())
        }
    }

    struct Submodule {
        let viewController: UIViewController
        let view: UIView?
        let isLanguageDependent: Bool
    }
}

extension ExploreViewController: ExploreViewControllerProtocol {
    func displayContent(viewModel: Explore.LoadContent.ViewModel) {
        switch viewModel.state {
        case .normal(let language):
            self.removeLanguageDependentSubmodules()
            self.initLanguageDependentSubmodules(contentLanguage: language)
        case .loading:
            break
        }

    }
}
