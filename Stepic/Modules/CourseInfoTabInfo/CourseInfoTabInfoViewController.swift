//
//  CourseInfoTabInfoViewController.swift
//  stepik-ios
//
//  Created by Ivan Magda on 15/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol CourseInfoTabInfoViewControllerProtocol: class {
    func displayCourseInfo(viewModel: CourseInfoTabInfo.ShowInfo.ViewModel)
}

final class CourseInfoTabInfoViewController: UIViewController {
    let interactor: CourseInfoTabInfoInteractorProtocol

    private lazy var infoView = self.view as? CourseInfoTabInfoView

    private var state: CourseInfoTabInfo.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    private var playerVideoBoundsObservation: NSKeyValueObservation?

    @objc
    private dynamic lazy var playerViewController: AVPlayerViewController = {
        let playerViewController = AVPlayerViewController()
        self.playerVideoBoundsObservation = playerViewController.observe(
            \.videoBounds,
            options: [.old, .new]
        ) { _, change in
            guard let oldValue = change.oldValue,
                  let newValue = change.newValue else {
                return
            }

            if newValue.size.height != oldValue.size.height {
                UIApplication.shared.isStatusBarHidden = false
            }
        }
        return playerViewController
    }()

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

    deinit {
        self.playerVideoBoundsObservation = nil
        self.playerViewController.willMove(toParentViewController: nil)
        self.playerViewController.view.removeFromSuperview()
        self.playerViewController.removeFromParentViewController()
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        self.view = CourseInfoTabInfoView(delegate: self)
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

    private func display(newState: CourseInfoTabInfo.ViewControllerState) {
        if case .result(let viewModel) = newState {
            self.infoView?.configure(viewModel: viewModel)
        }

        self.state = newState
    }
}

// MARK: - CourseInfoTabInfoViewController: CourseInfoTabInfoIntroVideoBlockViewDelegate -

extension CourseInfoTabInfoViewController: CourseInfoTabInfoIntroVideoBlockViewDelegate {
    func courseInfoTabInfoIntroVideoBlockViewRequestsVideoView(
        _ courseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView
    ) -> UIView {
        self.addChildViewController(self.playerViewController)
        return self.playerViewController.view
    }

    func courseInfoTabInfoIntroVideoBlockViewDidAddVideoView(
        _ courseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView
    ) {
        self.playerViewController.didMove(toParentViewController: self)
    }

    func courseInfoTabInfoIntroVideoBlockViewDidReceiveVideoURL(
        _ courseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView,
        url: URL
    ) {
        if self.playerViewController.player == nil {
            self.playerViewController.player = AVPlayer(url: url)
        }
    }

    func courseInfoTabInfoIntroVideoBlockViewPlayClicked(
        _ courseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView
    ) {
        self.playerViewController.player?.play()
    }
}

// MARK: - CourseInfoTabInfoViewController: CourseInfoTabInfoViewDelegate -

extension CourseInfoTabInfoViewController: CourseInfoTabInfoViewDelegate {
    func courseInfoTabInfoViewDidClickInstructor(
        _ courseInfoTabInfoView: CourseInfoTabInfoView,
        instructor: CourseInfoTabInfoInstructorViewModel
    ) {
        let module = ProfileAssembly(userID: instructor.id).makeModule()
        if let module = module as? ProfileViewController {
            self.navigationController?.pushViewController(module, animated: true)
        }
    }
}
