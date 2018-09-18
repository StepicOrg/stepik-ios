//
//  ExploreExploreViewController.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ExploreViewControllerProtocol: class {
    func displaySomething(viewModel: Explore.Something.ViewModel)
}

final class ExploreViewController: UIViewController {
    let interactor: ExploreInteractorProtocol
    private var state: Explore.ViewControllerState

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

        let contentLanguageSwitchAssembly = ContentLanguageSwitchAssembly()
        let clViewController = contentLanguageSwitchAssembly.makeModule()
        self.addChildViewController(clViewController)
        view.addBlockView(clViewController.view)

        let tagsAssembly = TagsAssembly()
        let tagsViewController = tagsAssembly.makeModule()
        self.addChildViewController(tagsViewController)
        view.addBlockView(tagsViewController.view)

        let collectionAssembly = CourseListsCollectionAssembly()
        let collectionViewController = collectionAssembly.makeModule()
        self.addChildViewController(collectionViewController)
        view.addBlockView(collectionViewController.view)

        let popularAssembly = CourseListAssembly(type: PopularCourseListType(language: .english), colorMode: .dark)
        let popularViewController = popularAssembly.makeModule()
        popularAssembly.moduleInput?.reload()
        self.addChildViewController(popularViewController)

        let container = CourseListContainerViewFactory(colorMode: .dark)
            .makeHorizontalContainerView(
                for: popularViewController.view,
                headerDescription: .init(title: "Popular", summary: nil)
            )
        view.addBlockView(container)

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.someAction()
    }

    // MARK: Requests logic

    private func someAction() {
        self.interactor.doSomeAction(
            request: Explore.Something.Request()
        )
    }
}

extension ExploreViewController: ExploreViewControllerProtocol {
    func displaySomething(viewModel: Explore.Something.ViewModel) {
        display(newState: viewModel.state)
    }

    func display(newState: Explore.ViewControllerState) {
        self.state = newState
    }
}
