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
    func displayTooltip(viewModel: ContinueCourse.CheckTooltipAvailability.ViewModel)
}

final class ContinueCourseViewController: UIViewController {
    let interactor: ContinueCourseInteractorProtocol
    private var state: ContinueCourse.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    lazy var continueCourseView = self.view as? ContinueCourseView
    private lazy var continueLearningTooltip = TooltipFactory.continueLearningWidget

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
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState()
        self.interactor.loadLastCourse(request: .init())
    }

    private func updateState() {
        if case .loading = self.state {
            self.continueCourseView?.showLoading()
        } else {
            self.continueCourseView?.hideLoading()
        }
    }
}

extension ContinueCourseViewController: ContinueCourseViewControllerProtocol {
    func displayLastCourse(viewModel: ContinueCourse.LoadLastCourse.ViewModel) {
        if case .result(let result) = viewModel.state {
            self.continueCourseView?.configure(with: result)
            self.interactor.checkForTooltip(request: .init())
        }

        self.state = viewModel.state
    }

    func displayTooltip(viewModel: ContinueCourse.CheckTooltipAvailability.ViewModel) {
        guard let continueCourseView = self.continueCourseView else {
            return
        }

        if viewModel.shouldShowTooltip {
            self.continueLearningTooltip.show(
                direction: .up,
                in: continueCourseView,
                from: continueCourseView.tooltipAnchorView
            )
        }
    }
}

extension ContinueCourseViewController: ContinueCourseViewDelegate {
    func continueCourseContinueButtonDidClick(_ continueCourseView: ContinueCourseView) {
        self.interactor.continueLastCourse(request: .init())
    }
}
