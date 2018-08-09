//
//  StepViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Agrume
import PromiseKit
import SnapKit

class StepViewController: UIViewController, StepView {
    private struct Theme {
        static let viewInitialHeight: CGFloat = 5.0

        struct StepWebView {
            static let horizontalSpacing: CGFloat = 2.0
            static let topSpacing: CGFloat = 5.0
        }
    }

    // MARK: - Instance Properties

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    private var stepWebViewHeight: Constraint!
    private weak var quizView: UIView?
    private lazy var quizPlaceholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    var presenter: StepPresenter?

    private lazy var stepWebView: StepWebView = {
        let stepWebView = StepWebView()
        stepWebView.translatesAutoresizingMaskIntoConstraints = false
        stepWebView.scrollView.isScrollEnabled = false

        return stepWebView
    }()

    // For updates after rotation only when controller not presented
    private var shouldRefreshOnAppear: Bool = false

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()

        activityIndicator.startAnimating()
        presenter?.refreshStep()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        triggerViewLayoutUpdate()

        if shouldRefreshOnAppear {
            refreshWebView()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldRefreshOnAppear = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - StepView

    func update(with htmlText: String) {
        let processor = HTMLProcessor(html: htmlText)
        let html = processor.injectDefault().html
        stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }

    func updateQuiz(with controller: UIViewController) {
        quizView = controller.view
        addChildViewController(controller)

        quizPlaceholderView.addSubview(quizView!)
        quizView!.snp.makeConstraints {
            $0.edges.equalTo(quizPlaceholderView)
        }
        controller.didMove(toParentViewController: self)

        triggerViewLayoutUpdate()
    }


    // MARK: - Private API

    private func triggerViewLayoutUpdate() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func setup() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didScreenRotate),
            name: .UIDeviceOrientationDidChange,
            object: nil
        )

        setupQuizPlaceholderView()
        setupWebView()
    }

    @objc private func didScreenRotate() {
        refreshWebView()
        shouldRefreshOnAppear = !shouldRefreshOnAppear
    }

    private func setupQuizPlaceholderView() {
        scrollView.addSubview(quizPlaceholderView)
        quizPlaceholderView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.trailing.leading.bottom.equalToSuperview()
        }
    }

    private func setupWebView() {
        scrollView.insertSubview(stepWebView, at: 0)
        stepWebView.snp.makeConstraints { make in
            stepWebViewHeight = make.height.equalTo(Theme.viewInitialHeight).constraint
            make.bottom.equalTo(quizPlaceholderView.snp.top)
            make.leading.equalTo(scrollView).offset(Theme.StepWebView.horizontalSpacing)
            make.trailing.equalTo(scrollView).offset(-Theme.StepWebView.horizontalSpacing)
            make.top.equalTo(scrollView).offset(Theme.StepWebView.topSpacing)
        }

        stepWebView.didFinishNavigation = { [weak self] _ in
            guard let `self` = self else {
                return
            }

            self.stepWebView.alignImages().then {
                self.stepWebView.getContentHeight()
            }.done { [weak self] height in
                self?.resetWebViewHeight(Float(height))
                self?.triggerViewLayoutUpdate()
                self?.activityIndicator.stopAnimating()
            }.catch { error in
                print("Error after did finish navigation: \(error)")
            }
        }

        stepWebView.onOpenImage = { [weak self] imageURL in
            guard let `self` = self else {
                return
            }

            Agrume(imageUrl: imageURL).showFrom(self)
        }
    }

    private func resetWebViewHeight(_ height: Float) {
        stepWebViewHeight.update(offset: height)
    }

    private func refreshWebView() {
        assert(Thread.isMainThread)

        activityIndicator.startAnimating()
        resetWebViewHeight(5.0)

        stepWebView.reloadContent().then {
            self.stepWebView.alignImages()
        }.then {
            self.stepWebView.getContentHeight()
        }.done { [weak self] height in
            self?.resetWebViewHeight(Float(height))
            self?.triggerViewLayoutUpdate()
            self?.activityIndicator.stopAnimating()
        }.catch { error in
            print("Error while refreshing: \(error)")
        }
    }
}
