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
        let headerHeight: CGFloat = 240.0
        let segmentedControlHeight: CGFloat = 44.0
    }
}

final class CourseInfoView: UIView {
    let appearance: Appearance

    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView(frame: .zero, orientation: .vertical)
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()

    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainDark
        return view
    }()

    private lazy var segmentedControl: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        return view
    }()
    private lazy var fakeContentView = UIView()

    // Dynamic scrolling constraints
    private var topConstraint: Constraint?
    private var headerHeightConstraint: Constraint?

    init(
        frame: CGRect,
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

    func updateScroll(offset: CGFloat) {
        // default position: offset == 0
        // overscroll (parallax effect): offset < 0
        // normal scrolling: offset > 0
        if offset <= 0 {
            self.headerHeightConstraint?.update(offset: self.appearance.headerHeight + -offset)
        }

        if offset >= 0 {
            self.topConstraint?.update(offset: -offset)
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
        self.backgroundColor = .white

        let headerInset = UIEdgeInsets(
            top: self.appearance.headerHeight + self.appearance.segmentedControlHeight,
            left: 0,
            bottom: 0,
            right: 0
        )
        self.scrollableStackView.contentInsets = headerInset
    }

    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(self.segmentedControl)
        self.insertSubview(self.scrollableStackView, aboveSubview: self.headerView)

        self.scrollableStackView.addArrangedView(self.fakeContentView)
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
            self.headerHeightConstraint = make.height.equalTo(self.appearance.headerHeight).constraint
        }

        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.segmentedControlHeight)
        }

        self.fakeContentView.translatesAutoresizingMaskIntoConstraints = false
        self.fakeContentView.snp.makeConstraints { make in
            make.height.equalTo(1200)
        }
    }
}
