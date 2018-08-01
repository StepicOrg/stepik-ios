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
    @IBOutlet var placeholderView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    private var stepWebViewHeight: Constraint!

    // MARK: Instance Properties

    var presenter: StepPresenter?

    private lazy var stepWebView: StepWebView = {
        let stepWebView = StepWebView()
        stepWebView.translatesAutoresizingMaskIntoConstraints = false

        return stepWebView
    }()

    // For updates after rotation only when controller not presented
    var shouldRefreshOnAppear: Bool = false

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

        view.setNeedsLayout()
        view.layoutIfNeeded()

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

    // MARK: - Private API

    @objc func didScreenRotate() {
        refreshWebView()
        shouldRefreshOnAppear = !shouldRefreshOnAppear
    }

    private func setupWebView() {
        scrollView.insertSubview(stepWebView, at: 0)
        stepWebView.snp.makeConstraints { make in
            stepWebViewHeight = make.height.equalTo(5).constraint
            make.bottom.equalTo(placeholderView.snp.top)
            make.leading.equalTo(scrollView).offset(2)
            make.trailing.equalTo(scrollView).offset(-2)
            make.top.equalTo(scrollView).offset(5)
        }

        stepWebView.didFinishNavigation = { [weak self] _ in
            guard let `self` = self else {
                return
            }

            self.stepWebView.alignImages().then {
                self.stepWebView.getContentHeight()
            }.done { [weak self] height in
                self?.resetWebViewHeight(Float(height))
                self?.scrollView.layoutIfNeeded()
                self?.animate()
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
        activityIndicator.startAnimating()
        resetWebViewHeight(5.0)

        stepWebView.reloadContent().then {
            self.stepWebView.alignImages()
        }.then {
            self.stepWebView.getContentHeight()
        }.done { [weak self] height in
            self?.resetWebViewHeight(Float(height))
            self?.scrollView.layoutIfNeeded()
            self?.animate()
        }.catch { error in
            print("Error while refreshing: \(error)")
        }
    }

    private func animate() {
        stepWebView.alpha = 0.0
        UIView.animate(withDuration: 0.33, animations: {
            self.stepWebView.alpha = 1.0
        }, completion: { finished in
            guard finished else {
                return
            }
            self.stepWebView.scrollView.contentOffset = .zero
            self.activityIndicator.stopAnimating()
        })
    }
}
