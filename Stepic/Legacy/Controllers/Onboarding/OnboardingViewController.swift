//
//  OnboardingViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class OnboardingViewController: UIViewController {
    @IBOutlet var closeButton: UIBarButtonItem!
    @IBOutlet weak var animatedView: OnboardingAnimatedView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var secondStackView: UIStackView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightParentView: UIView!
    @IBOutlet weak var rightParentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightParentViewBottomConstraint: NSLayoutConstraint!

    private var currentPageIndex = 0

    private var scrollView: UIScrollView!
    private var pages: [OnboardingPageView] = []

    var authSource: UIViewController? {
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController
    }

    private var backgroundGradient = CAGradientLayer(colors: [UIColor(hex6: 0x3a3947), UIColor(hex6: 0x5d6780)], rotationAngle: -50.0)

    private var titles = (1...4).map { NSLocalizedString("OnboardingTitle\($0)", comment: "") }
    private var descriptions = (1...4).map { NSLocalizedString("OnboardingDescription\($0)", comment: "") }

    private var shouldUseLandscapeLayout: Bool {
        DeviceInfo.current.orientation.interface.isLandscape
    }

    private let notificationsRegistrationService: NotificationsRegistrationServiceProtocol = NotificationsRegistrationService(
        presenter: NotificationsRequestOnlySettingsAlertPresenter(),
        analytics: .init(source: .onboarding)
    )

    private let analytics: Analytics = StepikAnalytics.shared

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = UIColor.clear

        mainStackView.axis = shouldUseLandscapeLayout ? .horizontal : .vertical

        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.contentSize.width = CGFloat(titles.count) * self.view.frame.width
        scrollView.isPagingEnabled = true
        scrollView.frame = self.view.frame
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        view.insertSubview(scrollView, aboveSubview: pageControl)

        backgroundGradient.frame = view.bounds
        view.layer.insertSublayer(self.backgroundGradient, at: 0)

        closeButton.accessibilityIdentifier = AccessibilityIdentifiers.Onboarding.closeButton
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.reloadPages()
        self.analytics.send(.onboardingScreenOpened(index: currentPageIndex + 1))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.animatedView.start()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        mainStackView.axis = shouldUseLandscapeLayout ? .horizontal : .vertical
        topConstraint.constant = shouldUseLandscapeLayout ? 0.0 : 16.0
        bottomConstraint.constant = shouldUseLandscapeLayout ? (navigationController?.navigationBar.frame.height ?? 40) : 16.0

        backgroundGradient.frame = view.bounds
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        DispatchQueue.main.async {
            // Recalculate pages frames and update scroll view offset
            self.reloadPages()

            let newScrollViewContentOffsetX = CGFloat(self.currentPageIndex) * self.scrollView.frame.width
            self.scrollView.bounds.origin = CGPoint(x: newScrollViewContentOffsetX, y: self.scrollView.contentOffset.y)
        }
    }

    @IBAction func onCloseButtonClick(_ sender: Any) {
        self.dismiss(animated: true) {
            self.analytics.send(.onboardingScreenClosed(index: self.currentPageIndex + 1))
            self.notificationsRegistrationService.registerForRemoteNotifications()
        }
    }

    private func reloadPages() {
        let rightParentViewConvertedFrame = view.convert(rightParentView.frame, from: mainStackView)
        scrollView.bounds.origin = CGPoint.zero
        scrollView.frame = shouldUseLandscapeLayout ? rightParentViewConvertedFrame : view.frame
        scrollView.contentSize.width = CGFloat(titles.count) * (shouldUseLandscapeLayout ? rightParentViewConvertedFrame.width : view.frame.width)

        if pages.isEmpty {
            for i in 0..<titles.count {
                let pageView = OnboardingPageView()
                pageView.pageTitleLabel.text = titles[i]
                pageView.pageDescriptionLabel.text = descriptions[i]
                pageView.pageDescriptionLabel.sizeToFit()
                pageView.buttonStyle = (i == titles.count - 1) ? .start : .next
                pageView.onClick = { [weak self] in
                    self?.nextButtonClick()
                }

                scrollView.addSubview(pageView)
                pages.append(pageView)
            }
        }

        // Change width, cause we should have resized pageView before text height calculation
        // containerView width is constant after rotation, so we can use it safely
        for i in 0..<pages.count {
            pages[i].frame = CGRect(x: pages[i].frame.origin.x, y: pages[i].frame.origin.y, width: containerView.frame.width, height: containerView.frame.height)
            pages[i].layoutIfNeeded()
        }

        // Calculate estimated text height
        let descriptionsHeights = pages.map { $0.descriptionHeight }
        let maxDescriptionsHeight = descriptionsHeights.max() ?? 0
        (0..<pages.count).forEach { index in
            let estimatedHeight = descriptionsHeights[index]
            pages[index].updateHeight(maxDescriptionsHeight - estimatedHeight)
        }

        if shouldUseLandscapeLayout {
            let maxPagesHeight = pages.map { $0.height }.max() ?? 0
            rightParentViewTopConstraint.constant = (rightParentView.bounds.size.height - maxPagesHeight - pageControl.bounds.size.height - secondStackView.spacing) / 2
            rightParentViewBottomConstraint.constant = rightParentViewTopConstraint.constant
        } else {
            rightParentViewTopConstraint.constant = 0
            rightParentViewBottomConstraint.constant = 0
        }
        rightParentView.layoutIfNeeded()

        let convertedCoordinates = scrollView.convert(containerView.frame, from: secondStackView)
        for i in 0..<pages.count {
            let xPosition = convertedCoordinates.origin.x + CGFloat(i) * scrollView.frame.width
            let yPosition = convertedCoordinates.origin.y

            pages[i].frame = CGRect(x: xPosition, y: yPosition, width: containerView.frame.width, height: containerView.frame.height)
        }

        // Update alpha to add fade to scrolling
        if currentPageIndex >= 0 && currentPageIndex < pages.count {
            pages[currentPageIndex].alpha = 1.0
        }
        if currentPageIndex - 1 >= 0 {
            pages[currentPageIndex - 1].alpha = 0.0
        }
        if currentPageIndex + 1 < pages.count {
            pages[currentPageIndex + 1].alpha = 0.0
        }
    }

    private func nextButtonClick() {
        if currentPageIndex < pages.count - 1 {
            let newScrollViewContentOffsetX = CGFloat(currentPageIndex + 1) * scrollView.frame.width
            scrollView.setContentOffset(CGPoint(x: newScrollViewContentOffsetX, y: scrollView.contentOffset.y), animated: true)
        } else {
            self.analytics.send(.onboardingCompleted)

            self.dismiss(animated: true, completion: {
                self.notificationsRegistrationService.registerForRemoteNotifications()
            })

            if let authSource = authSource {
                RoutingManager.auth.routeFrom(
                    controller: authSource,
                    success: {
                        TabBarRouter(tab: .profile).route()
                    },
                    cancel: nil
                )
            }
        }
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        animatedView?.play()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = scrollView.contentOffset.x / scrollView.frame.width
        animatedView?.flip(percent: Double(offset), didInteractionFinished: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !pages.isEmpty else {
            return
        }

        let offset = scrollView.contentOffset.x / scrollView.frame.width
        let page = Int(offset)
        pageControl.currentPage = page

        if page != currentPageIndex {
            currentPageIndex = page
            self.analytics.send(.onboardingScreenOpened(index: currentPageIndex + 1))
        }
        animatedView?.flip(percent: Double(offset), didInteractionFinished: false)

        // Animate alpha to add fade to scrolling
        let segmentPercent = offset - CGFloat(Int(page))
        if currentPageIndex >= 0 && currentPageIndex < pages.count {
            pages[currentPageIndex].alpha = 1.0 - 1.5 * segmentPercent
        }
        if currentPageIndex - 1 >= 0 {
            pages[currentPageIndex - 1].alpha = 1.5 * segmentPercent
        }
        if currentPageIndex + 1 < pages.count {
            pages[currentPageIndex + 1].alpha = 1.5 * segmentPercent
        }
    }
}
