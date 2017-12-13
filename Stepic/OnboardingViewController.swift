//
//  OnboardingViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

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

    fileprivate var currentPageIndex = 0

    private var scrollView: UIScrollView!
    fileprivate var pages: [OnboardingPageView] = []

    private var backgroundGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(hex: 0x3a3947).cgColor,
            UIColor(hex: 0x5d6780).cgColor
        ]

        let alpha: Float = 50.0 / 360.0
        let startPointX = powf(sinf(2 * Float.pi * ((alpha + 0.75) / 2)), 2)
        let startPointY = powf(sinf(2 * Float.pi * ((alpha + 0) / 2)), 2)
        let endPointX = powf(sinf(2 * Float.pi * ((alpha + 0.25) / 2)), 2)
        let endPointY = powf(sinf(2 * Float.pi * ((alpha + 0.5) / 2)), 2)

        gradient.endPoint = CGPoint(x: CGFloat(endPointX), y: CGFloat(endPointY))
        gradient.startPoint = CGPoint(x: CGFloat(startPointX), y: CGFloat(startPointY))
        return gradient
    }()

    private var titles = ["Выбирайте", "Сохраняйте", "Решайте", "Достигайте"]
    private var descriptions = [
        "Доступ ко всем курсам на Stepik – выбирайте что интересно",
        "Смотрите лекции и сохраняйте их для просмотра без доступа в сеть",
        "Решайте задачи прямо с мобильного устройства",
        "Установите напоминания, чтобы заниматься регулярнее и быстрее закончить курс"
    ]

    fileprivate var isLandscape: Bool {
        switch DeviceInfo.current.orientation {
        case .landscapeLeft, .landscapeRight:
            return true
        default:
            return false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = UIColor.clear

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "onboarding-close"), style: .plain, target: nil, action: nil)

        mainStackView.axis = isLandscape ? .horizontal : .vertical

        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.contentSize.width = CGFloat(titles.count) * self.view.frame.width
        scrollView.isPagingEnabled = true
        scrollView.frame = self.view.frame
        scrollView.showsHorizontalScrollIndicator = false
        view.insertSubview(scrollView, aboveSubview: pageControl)

        backgroundGradient.frame = view.bounds
        view.layer.insertSublayer(self.backgroundGradient, at: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        reloadPages()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.animatedView.start()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        mainStackView.axis = isLandscape ? .horizontal : .vertical
        topConstraint.constant = isLandscape ? 0.0 : 16.0
        bottomConstraint.constant = isLandscape ? (navigationController?.navigationBar.frame.height ?? 40) : 16.0

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

    private func reloadPages() {
        let rightParentViewConvertedFrame = view.convert(rightParentView.frame, from: mainStackView)
        scrollView.bounds.origin = CGPoint.zero
        scrollView.frame = isLandscape ? rightParentViewConvertedFrame : view.frame
        scrollView.contentSize.width = CGFloat(titles.count) * (isLandscape ? rightParentViewConvertedFrame.width : view.frame.width)

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

        // Calculate estimated text height
        let descriptionsHeights = pages.map { UILabel.heightForLabelWithText($0.pageDescriptionLabel.text ?? "", lines: 0, standardFontOfSize: $0.pageDescriptionLabel.font.pointSize, width: containerView.frame.width - 32) }
        let maxDescriptionsHeight = descriptionsHeights.max() ?? 0
        (0..<pages.count).forEach { index in
            let estimatedHeight = descriptionsHeights[index]
            pages[index].updateHeight(maxDescriptionsHeight - estimatedHeight)
        }

        if isLandscape {
            let maxPagesHeight = pages.map { $0.height }.max() ?? 0
            rightParentViewTopConstraint.constant = (rightParentView.bounds.size.height - maxPagesHeight - pageControl.bounds.size.height - secondStackView.spacing) / 2
            rightParentViewBottomConstraint.constant = rightParentViewTopConstraint.constant
            rightParentView.layoutIfNeeded()
        }

        let convertedCoordinates = scrollView.convert(containerView.frame, from: secondStackView)
        for i in 0..<pages.count {
            let xPosition = convertedCoordinates.origin.x + CGFloat(i) * scrollView.frame.width
            let yPosition = convertedCoordinates.origin.y

            pages[i].frame = CGRect(x: xPosition, y: yPosition, width: containerView.frame.width, height: containerView.frame.height)
        }

        // Update alpha to add fade to scrolling
        pages[currentPageIndex].alpha = 1.0
        if currentPageIndex - 1 >= 0 {
            pages[currentPageIndex - 1].alpha = 0.0
        }
        if currentPageIndex + 1 < pages.count {
            pages[currentPageIndex + 1].alpha = 0.0
        }
    }

    private func nextButtonClick() {
        if currentPageIndex < pages.count - 1 {
            currentPageIndex += 1

            let newScrollViewContentOffsetX = CGFloat(self.currentPageIndex) * self.scrollView.frame.width
            scrollView.setContentOffset(CGPoint(x: newScrollViewContentOffsetX, y: self.scrollView.contentOffset.y), animated: true)
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
        let offset = scrollView.contentOffset.x / scrollView.frame.width
        let page = Int(offset)
        pageControl.currentPage = page

        if page != currentPageIndex {
            currentPageIndex = page
        }
        animatedView?.flip(percent: Double(offset), didInteractionFinished: false)

        // Animate alpha to add fade to scrolling
        let segmentPercent = offset - CGFloat(Int(page))
        pages[currentPageIndex].alpha = 1.0 - 1.5 * segmentPercent
        if currentPageIndex - 1 >= 0 {
            pages[currentPageIndex - 1].alpha = 1.5 * segmentPercent
        }
        if currentPageIndex + 1 < pages.count {
            pages[currentPageIndex + 1].alpha = 1.5 * segmentPercent
        }
    }
}
