//
//  HomeHomeViewController.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 17/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol HomeViewControllerProtocol: class {
    func displaySomething(viewModel: Home.Something.ViewModel)
}

final class HomeViewController: UIViewController {
    let interactor: HomeInteractorProtocol
    private var state: Home.ViewControllerState

    init(
        interactor: HomeInteractorProtocol,
        initialState: Home.ViewControllerState = .loading
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

        let view1 = StreakActivityView(frame: .zero)
        view.addBlockView(view1)

        let view2 = ContinueLastStepView(frame: .zero)
        view.addBlockView(view2)

        let popularAssembly = CourseListAssembly(type: PopularCourseListType(language: .english), colorMode: .light)
        let popularViewController = popularAssembly.makeModule()
        popularAssembly.getModuleInput().reload()
        self.addChildViewController(popularViewController)
        let hv = ExploreBlockHeaderView(
            frame: .zero,
            appearance: CourseListColorMode.light.exploreBlockHeaderViewAppearance
        )
        hv.titleText = "Мои курсы"
        hv.summaryText = "8 курсов"
        hv.shouldShowShowAllButton = true

        var appearance = CourseListColorMode.light.exploreBlockContainerViewAppearance
        appearance.contentViewInsets.top = 0
        appearance.contentViewInsets.bottom = 16
        let container = ExploreBlockContainerView(
            frame: .zero,
            headerView: hv,
            contentView: popularViewController.view,
            shouldShowSeparator: false,
            appearance: appearance
        )
        view.addBlockView(container)

        let popularAssembly1 = CourseListAssembly(type: PopularCourseListType(language: .english), colorMode: .dark)
        let popularViewController1 = popularAssembly1.makeModule()
        popularAssembly1.getModuleInput().reload()
        self.addChildViewController(popularViewController1)
        let hv1 = ExploreBlockHeaderView(
            frame: .zero,
            appearance: CourseListColorMode.dark.exploreBlockHeaderViewAppearance
        )
        hv1.titleText = "Популярные"

        var appearance1 = CourseListColorMode.dark.exploreBlockContainerViewAppearance
        appearance1.contentViewInsets.top = 0
        appearance1.contentViewInsets.bottom = 16
        let container1 = ExploreBlockContainerView(
            frame: .zero,
            headerView: hv1,
            contentView: popularViewController1.view,
            shouldShowSeparator: false,
            appearance: appearance1
        )
        view.addBlockView(container1)

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.someAction()
    }

    // MARK: Requests logic

    private func someAction() {
        self.interactor.doSomeAction(
            request: Home.Something.Request()
        )
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    func displaySomething(viewModel: Home.Something.ViewModel) {
        display(newState: viewModel.state)
    }

    func display(newState: Home.ViewControllerState) {
        self.state = newState
    }
}
