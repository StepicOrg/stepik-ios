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

        // Enrolled
        let enrolledAssembly = CourseListAssembly(
            type: EnrolledCourseListType(),
            colorMode: .light
        )
        let enrolledViewController = enrolledAssembly.makeModule()
        enrolledAssembly.moduleInput?.reload()
        self.addChildViewController(enrolledViewController)
        let enrolledContainerView = CourseListContainerViewFactory(colorMode: .light)
            .makeHorizontalContainerView(
                for: enrolledViewController.view,
                headerDescription: .init(
                    title: NSLocalizedString("MyCourses", comment: ""),
                    summary: "???"
                )
            )
        view.addBlockView(enrolledContainerView)

        // Popular
        let popularAssembly = CourseListAssembly(
            type: PopularCourseListType(language: .russian),
            colorMode: .dark
        )
        let popularViewController = popularAssembly.makeModule()
        popularAssembly.moduleInput?.reload()
        self.addChildViewController(popularViewController)
        let popularContainerView = CourseListContainerViewFactory(colorMode: .dark)
            .makeHorizontalContainerView(
                for: popularViewController.view,
                headerDescription: .init(
                    title: NSLocalizedString("Popular", comment: ""),
                    summary: nil
                )
            )
        view.addBlockView(popularContainerView)

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
