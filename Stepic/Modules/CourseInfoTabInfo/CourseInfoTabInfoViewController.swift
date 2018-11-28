//
//  CourseInfoTabInfoViewController.swift
//  stepik-ios
//
//  Created by Ivan Magda on 15/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol CourseInfoTabInfoViewControllerProtocol: class {
    func displayCourseInfo(viewModel: CourseInfoTabInfo.ShowInfo.ViewModel)

    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showErrorIndicator(message: String?)
}

final class CourseInfoTabInfoViewController: UIViewController {
    let interactor: CourseInfoTabInfoInteractorProtocol

    private lazy var infoView = self.view as? CourseInfoTabInfoView

    private var state: CourseInfoTabInfo.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    // MARK: Init

    init(
        interactor: CourseInfoTabInfoInteractorProtocol,
        initialState: CourseInfoTabInfo.ViewControllerState = .loading
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
        self.view = CourseInfoTabInfoView(delegate: self, videoViewDelegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState()
        self.interactor.getCourseInfo()
    }

    // MARK: Private helpers

    private func updateState() {
        if case .loading = self.state {
            self.infoView?.showLoading()
        } else {
            self.infoView?.hideLoading()
        }
    }
}

// MARK: - CourseInfoTabInfoViewController: CourseInfoTabInfoViewControllerProtocol -

extension CourseInfoTabInfoViewController: CourseInfoTabInfoViewControllerProtocol {
    func displayCourseInfo(viewModel: CourseInfoTabInfo.ShowInfo.ViewModel) {
        self.display(newState: viewModel.state)
    }

    func showLoadingIndicator() {
        SVProgressHUD.show()
    }

    func hideLoadingIndicator() {
        SVProgressHUD.dismiss()
    }

    func showErrorIndicator(message: String?) {
        SVProgressHUD.showError(withStatus: message)
    }

    private func display(newState: CourseInfoTabInfo.ViewControllerState) {
        if case .result(let viewModel) = newState {
            self.infoView?.configure(viewModel: viewModel)
        }

        self.state = newState
    }
}

// MARK: - CourseInfoTabInfoViewController: CourseInfoTabInfoViewDelegate -

extension CourseInfoTabInfoViewController: CourseInfoTabInfoViewDelegate {
    func courseInfoTabInfoViewDidTapOnActionButton(_ courseInfoTabInfoView: CourseInfoTabInfoView) {
        self.interactor.doCourseAction()
    }
}

// MARK: - CourseInfoTabInfoViewController: CourseInfoTabInfoIntroVideoBlockViewDelegate -

extension CourseInfoTabInfoViewController: CourseInfoTabInfoIntroVideoBlockViewDelegate {
    var playerParentViewController: UIViewController? {
        return self
    }

    func courseInfoTabInfoIntroVideoBlockViewDidDismissFullscreen(
        _ CourseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView
    ) {
        self.setNeedsStatusBarAppearanceUpdate()
    }
}
