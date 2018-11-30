//
//  CourseInfoTabSyllabusSectionDeadlinesView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabSyllabusSectionDeadlinesView {
    struct Appearance {
        let verticalHorizontalOffset: CGFloat = 40
        let labelTopOffset: CGFloat = 6
        let labelsSpacing: CGFloat = 20

        let secondaryProgressColor = UIColor(hex: 0xb4b4bd)
        let mainProgressColor = UIColor.mainDark

        let progressIndicatorHeight: CGFloat = 1.5
        let labelTextColor = UIColor.mainDark
        let labelFont = UIFont.systemFont(ofSize: 13, weight: .light)

        let circleIndicatorRadius: CGFloat = 6.5
    }
}

final class CourseInfoTabSyllabusSectionDeadlinesView: UIView {
    private static let pagingVelocityThreshold: CGFloat = 0.6
    let appearance: Appearance

    private let items: [Item]

    private var circleIndicators: [CAShapeLayer] = []
    private var progressIndicators: [UIProgressView] = []
    private var textLabels: [UILabel] = []

    // Store labels per page
    private var labelsInPageCount = 0

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.delegate = self
        return scrollView
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: self.scrollView.frame.height)
    }

    init(frame: CGRect = .zero, items: [Item] = [], appearance: Appearance = Appearance()) {
        self.appearance = appearance
        self.items = items
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

        self.initItems()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateLayout()
        self.invalidateIntrinsicContentSize()
    }

    private func initItems() {
        for item in self.items {
            // Circle
            let circleIndicator = CAShapeLayer()
            circleIndicator.backgroundColor = UIColor.clear.cgColor
            circleIndicator.fillColor = item.isCompleted
                ? self.appearance.mainProgressColor.cgColor
                : self.appearance.secondaryProgressColor.cgColor
            self.scrollView.layer.addSublayer(circleIndicator)
            self.circleIndicators.append(circleIndicator)

            // Label
            let label = UILabel()
            label.numberOfLines = 2
            label.font = self.appearance.labelFont
            label.textColor = self.appearance.labelTextColor
            label.text = item.text
            label.sizeToFit()
            self.scrollView.addSubview(label)
            self.textLabels.append(label)
        }

        for index in 0..<(self.items.count - 1) {
            guard let nextItem = self.items[safe: index + 1] else {
                return
            }

            // Layer with progress
            // Last item will not have bar
            let progressIndicator = UIProgressView()
            progressIndicator.progressViewStyle = .bar
            progressIndicator.trackTintColor = self.appearance.secondaryProgressColor
            progressIndicator.progressTintColor = self.appearance.mainProgressColor
            progressIndicator.progress = nextItem.progressBefore
            self.scrollView.addSubview(progressIndicator)
            self.progressIndicators.append(progressIndicator)
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func updateLayout() {
        self.labelsInPageCount = 0
        var xOffset = self.appearance.verticalHorizontalOffset

        for (label, indicator) in zip(self.textLabels, self.circleIndicators) {
            let circleFrame = CGRect(
                x: 0,
                y: 0,
                width: self.appearance.circleIndicatorRadius,
                height: self.appearance.circleIndicatorRadius
            )
            indicator.path = UIBezierPath(ovalIn: circleFrame).cgPath
            indicator.frame = CGRect(
                x: xOffset,
                y: 0,
                width: self.appearance.circleIndicatorRadius,
                height: self.appearance.circleIndicatorRadius
            )

            label.frame = CGRect(
                x: xOffset,
                y: indicator.frame.maxY + self.appearance.labelTopOffset,
                width: label.frame.width,
                height: label.frame.height
            )

            xOffset += label.frame.width + self.appearance.labelsSpacing

            if xOffset < self.frame.width {
                self.labelsInPageCount += 1
            }
        }

        xOffset += self.appearance.verticalHorizontalOffset

        for index in 0..<(self.circleIndicators.count - 1) {
            guard let progressView = self.progressIndicators[safe: index],
                  let circleIndicator = self.circleIndicators[safe: index],
                  let nextCircleIndicator = self.circleIndicators[safe: index + 1] else {
                continue
            }

            progressView.frame = CGRect(
                x: circleIndicator.frame.midX,
                y: circleIndicator.frame.midY - self.appearance.progressIndicatorHeight / 2,
                width: nextCircleIndicator.frame.midX - circleIndicator.frame.midX,
                height: self.appearance.progressIndicatorHeight
            )
        }

        // Scrollview frame
        let scrollViewHeight = self.appearance.circleIndicatorRadius
            + self.appearance.labelTopOffset
            + (self.textLabels.map { $0.intrinsicContentSize.height }.max() ?? 0.0)

        self.scrollView.frame = CGRect(
            origin: self.scrollView.frame.origin,
            size: CGSize(width: self.scrollView.frame.width, height: scrollViewHeight)
        )
        self.scrollView.contentSize = CGSize(
            width: ceil(xOffset / self.scrollView.frame.width) * self.scrollView.frame.width,
            height: self.scrollView.frame.height
        )
    }

    struct Item {
        let text: String
        let progressBefore: Float
        let isCompleted: Bool
    }
}

extension CourseInfoTabSyllabusSectionDeadlinesView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.scrollView)
    }

    func makeConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension CourseInfoTabSyllabusSectionDeadlinesView: UIScrollViewDelegate {
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let currentPage = targetContentOffset.pointee.x / self.frame.width
        let nearestPage = round(currentPage)

        var pageDiff: CGFloat = 0
        if nearestPage < currentPage {
            if velocity.x >= CourseInfoTabSyllabusSectionDeadlinesView.pagingVelocityThreshold {
                pageDiff = 1
            }
        } else {
            if velocity.x <= -CourseInfoTabSyllabusSectionDeadlinesView.pagingVelocityThreshold {
                pageDiff = -1
            }
        }

        let index = max(0, min(self.textLabels.count - 1, Int(nearestPage + pageDiff)))
        guard let x = self.textLabels[safe: index * self.labelsInPageCount]?.frame.origin.x else {
            return
        }
        targetContentOffset.pointee.x = x - self.appearance.verticalHorizontalOffset
    }
}
