//
//  ContinueCourseContinueCourseViewController.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ContinueCourseViewControllerProtocol: class {
    func displayLastCourse(viewModel: ContinueCourse.LoadLastCourse.ViewModel)
}

final class ContinueCourseViewController: UIViewController {
    let interactor: ContinueCourseInteractorProtocol
    private var state: ContinueCourse.ViewControllerState

    lazy var continueCourseView = self.view as? ContinueCourseView

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

        self.interactor.loadLastCourse(request: .init())
    }
}

extension ContinueCourseViewController: ContinueCourseViewControllerProtocol {
    func displayLastCourse(viewModel: ContinueCourse.LoadLastCourse.ViewModel) {
        switch viewModel.state {
        case .result(let result):
            self.continueCourseView?.configure(with: result)
        case .loading:
            break
        }
    }
}
