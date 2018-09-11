//
//  ContinueCourseContinueCourseViewController.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ContinueCourseViewControllerProtocol: class {
    func displaySomething(viewModel: ContinueCourse.Something.ViewModel)
}

final class ContinueCourseViewController: UIViewController {
    let interactor: ContinueCourseInteractorProtocol
    private var state: ContinueCourse.ViewControllerState

    init(
        interactor: ContinueCourseInteractorProtocol,
        initialState: ContinueCourse.ViewControllerState = .loading
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
        let view = ContinueCourseView(
            frame: UIScreen.main.bounds
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
            request: ContinueCourse.Something.Request()
        )
    }
}

extension ContinueCourseViewController: ContinueCourseViewControllerProtocol {
    func displaySomething(viewModel: ContinueCourse.Something.ViewModel) {
        display(newState: viewModel.state)
    }

    func display(newState: ContinueCourse.ViewControllerState) {
        self.state = newState
    }
}
