//
//  FullscreenCourseListFullscreenCourseListViewController.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol FullscreenCourseListViewControllerProtocol: class {
    func displaySomething(viewModel: FullscreenCourseList.Something.ViewModel)
}

final class FullscreenCourseListViewController: UIViewController {
    let interactor: FullscreenCourseListInteractorProtocol
    private var state: FullscreenCourseList.ViewControllerState
    private let courseListType: CourseListType

    init(
        interactor: FullscreenCourseListInteractorProtocol,
        courseListType: CourseListType,
        initialState: FullscreenCourseList.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
        self.courseListType = courseListType

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let courseListAssembly = CourseListAssembly(
            type: self.courseListType,
            colorMode: .light,
            presentationOrientation: .vertical
        )
        let courseListViewController = courseListAssembly.makeModule()
        courseListAssembly.moduleInput?.reload()
        self.addChildViewController(courseListViewController)

        let view = FullscreenCourseListView(
            frame: UIScreen.main.bounds,
            contentView: courseListViewController.view
        )
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.someAction()
    }

    // MARK: Requests logic

    private func someAction() {
        self.interactor.doSomeAction(
            request: FullscreenCourseList.Something.Request()
        )
    }

    // MARK: Presentation description

    struct PresentationDescription {
        var title: String
        var subtitle: String?
    }
}

extension FullscreenCourseListViewController: FullscreenCourseListViewControllerProtocol {
    func displaySomething(viewModel: FullscreenCourseList.Something.ViewModel) {
        display(newState: viewModel.state)
    }

    func display(newState: FullscreenCourseList.ViewControllerState) {
        self.state = newState
    }
}
