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

    // MARK: IBOutlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    private var stepWebViewHeight: Constraint!

    // MARK: Instance Properties

    var presenter: StepPresenter?

    private lazy var stepWebView: StepWebView = {
        let stepWebView = StepWebView()
        stepWebView.translatesAutoresizingMaskIntoConstraints = false
        stepWebView.scrollView.isScrollEnabled = false

        return stepWebView
    }()

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didScreenRotate),
            name: .UIDeviceOrientationDidChange,
            object: nil
        )

        setupWebView()

        activityIndicator.startAnimating()
        presenter?.refreshStep()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.layoutIfNeeded()
        refreshWebView()
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

    // MARK: - Private API

    @objc func didScreenRotate() {
        refreshWebView()
    }

    private func setupWebView() {
        scrollView.insertSubview(stepWebView, at: 0)
        stepWebView.snp.makeConstraints { make in
            stepWebViewHeight = make.height.equalTo(5).constraint
            make.edges.equalTo(scrollView)
            make.centerX.equalTo(self.view)
        }

        stepWebView.didFinishNavigation = { [weak self] _ in
            guard let `self` = self else {
                return
            }

            self.stepWebView.alignImages().then {
                self.stepWebView.getContentHeight()
            }.done { [weak self] height in
                self?.resetWebViewHeight(Float(height))
                self?.view.layoutIfNeeded()
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
            self?.view.layoutIfNeeded()
            self?.activityIndicator.stopAnimating()
        }.catch { error in
            print("Error while refreshing: \(error)")
        }
    }
}
