//
//  CourseInfoView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoView {
    struct Appearance {
        let largeHeaderHeight: CGFloat = 265.0
        let headerHeight: CGFloat = 245.0
        let segmentedControlHeight: CGFloat = 60.0
    }
}

final class CourseInfoView: UIView {
    let appearance: Appearance

    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView(orientation: .vertical)
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()

    private lazy var headerView: CourseInfoHeaderView = {
        let view = CourseInfoHeaderView()
        return view
    }()

    private lazy var segmentedControl: TabSegmentedControlView = {
        let control = TabSegmentedControlView(frame: .zero, items: ["Инфо"])
        control.delegate = self
        return control
    }()

    private lazy var contentView: ScrollableStackView = {
        let stackView = ScrollableStackView(orientation: .horizontal)
        stackView.isPagingEnabled = true
        stackView.showsHorizontalScrollIndicator = false
        stackView.scrollDelegate = self
        return stackView
    }()

    var headerHeight: CGFloat {
        return DeviceInfo.current.isXSerie
            ? self.appearance.largeHeaderHeight
            : self.appearance.headerHeight
    }

    // Dynamic scrolling constraints
    private var topConstraint: Constraint?
    private var headerHeightConstraint: Constraint?

    init(
        frame: CGRect = .zero,
        scrollDelegate: UIScrollViewDelegate? = nil,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.scrollableStackView.scrollDelegate = scrollDelegate

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CourseInfoHeaderViewModel) {
        self.headerView.configure(viewModel: viewModel)
    }

    func updateScroll(offset: CGFloat) {
        // default position: offset == 0
        // overscroll (parallax effect): offset < 0
        // normal scrolling: offset > 0

        self.headerHeightConstraint?.update(
            offset: max(self.headerHeight, self.headerHeight + -offset)
        )

        self.topConstraint?.update(offset: min(0, -offset))
    }

    func addPageView(_ view: UIView) {
        self.contentView.addArrangedView(view)
        view.snp.makeConstraints { make in
            make.width.equalTo(self.snp.width)
        }

        if self.contentView.arrangedSubviews.count == 1 {
            self.setNeedsLayout()
            self.layoutIfNeeded()

            self.updatePageHeight(byPageWithIndex: 0)
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Dispatch hits to correct views

        let convertedPoint = self.convert(point, to: self.headerView)
        if self.headerView.bounds.contains(convertedPoint) {
            // Pass hits to header subviews
            for subview in self.headerView.subviews.reversed() {
                // Skip subview-receiver if it has isUserInteractionEnabled == false
                // to pass some hits to scrollview (e.g. swipes in header area)
                let shouldSubviewInteract = subview.isUserInteractionEnabled
                if subview.frame.contains(convertedPoint) && shouldSubviewInteract {
                    return subview
                }
            }
        }

        return super.hitTest(point, with: event)
    }
}

extension CourseInfoView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.clipsToBounds = true
        self.backgroundColor = .white

        let headerInset = UIEdgeInsets(
            top: self.headerHeight + self.appearance.segmentedControlHeight,
            left: 0,
            bottom: 0,
            right: 0
        )
        self.scrollableStackView.scrollIndicatorInsets = headerInset
        self.scrollableStackView.contentInsets = headerInset
    }

    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(self.segmentedControl)
        self.insertSubview(self.scrollableStackView, aboveSubview: self.headerView)

        self.scrollableStackView.addArrangedView(self.contentView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            self.topConstraint = make.top.equalToSuperview().constraint
            make.left.right.equalToSuperview()
            self.headerHeightConstraint = make.height.equalTo(self.headerHeight).constraint
        }

        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.segmentedControlHeight)
        }
    }
}

extension CourseInfoView: TabSegmentedControlViewDelegate {
    func tabSegmentedControlView(
        _ tabSegmentedControlView: TabSegmentedControlView,
        didSelectTabWithIndex: Int
    ) {
        guard didSelectTabWithIndex >= 0,
              didSelectTabWithIndex < self.contentView.arrangedSubviews.count else {
            return
        }

        self.contentView.scrollTo(arrangedViewIndex: didSelectTabWithIndex)
    }
}

// Delegate for horizontal content-stackview, not for parent vertical scrollview
extension CourseInfoView: UIScrollViewDelegate {
    private func updatePageHeight(byPageWithIndex index: Int) {
        let height = self.contentView.arrangedSubviews[index].intrinsicContentSize.height

        self.scrollableStackView.contentSize = CGSize(
            width: self.scrollableStackView.contentSize.width,
            height: height
        )
    }

    private func updateSegmentedControl(newPageIndex: Int) {
        self.segmentedControl.selectTab(index: newPageIndex)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let pageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            self.updatePageHeight(byPageWithIndex: pageIndex)
            self.updateSegmentedControl(newPageIndex: pageIndex)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        self.updatePageHeight(byPageWithIndex: pageIndex)
        self.updateSegmentedControl(newPageIndex: pageIndex)
    }
}
