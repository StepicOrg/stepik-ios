//
// Created by Ivan Magda on 11/7/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabInfoSkeletonView {
    struct Appearance {
        let labelsCornerRadius: CGFloat = 2
        let messageLabelsHeight: CGFloat = 37

        let authorViewInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 47)

        let introVideoViewOffsetTop: CGFloat = 20
        let introVideoViewHeight: CGFloat = 203

        let aboutHeaderViewInsets = UIEdgeInsets(top: 18, left: 20, bottom: 0, right: 47)
        let aboutMessageLabelInsets = UIEdgeInsets(top: 20, left: 47, bottom: 0, right: 47)

        let requirementsHeaderViewInsets = UIEdgeInsets(top: 32, left: 20, bottom: 0, right: 47)
        let requirementsMessageLabelInsets = UIEdgeInsets(top: 17, left: 47, bottom: 0, right: 47)
    }
}

final class CourseInfoTabInfoSkeletonView: UIView {
    private let appearance: Appearance

    private lazy var authorViewSkeleton: UIView = {
        CourseInfoTabInfoBlockSkeletonView(
            appearance: .init(titleLabelCornerRadius: self.appearance.labelsCornerRadius)
        )
    }()

    private lazy var introVideoViewSkeleton = UIView()

    private lazy var aboutHeaderViewSkeleton: UIView = {
        CourseInfoTabInfoBlockSkeletonView(
            appearance: .init(titleLabelCornerRadius: self.appearance.labelsCornerRadius)
        )
    }()
    private lazy var aboutMessageLabelSkeleton = UIView()

    private lazy var requirementsHeaderViewSkeleton: UIView = {
        CourseInfoTabInfoBlockSkeletonView(
            appearance: .init(titleLabelCornerRadius: self.appearance.labelsCornerRadius)
        )
    }()
    private lazy var requirementsMessageLabelSkeleton = UIView()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseInfoTabInfoSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        func setCornerRadius(_ radius: CGFloat, views: [UIView]) {
            views.forEach { view in
                view.clipsToBounds = true
                view.layer.cornerRadius = radius
            }
        }

        self.backgroundColor = .clear

        setCornerRadius(
            self.appearance.labelsCornerRadius,
            views: [
                self.aboutMessageLabelSkeleton,
                self.requirementsMessageLabelSkeleton
            ]
        )
    }

    func addSubviews() {
        self.addSubview(self.authorViewSkeleton)

        self.addSubview(self.introVideoViewSkeleton)

        self.addSubview(self.aboutHeaderViewSkeleton)
        self.addSubview(self.aboutMessageLabelSkeleton)

        self.addSubview(self.requirementsHeaderViewSkeleton)
        self.addSubview(self.requirementsMessageLabelSkeleton)
    }

    func makeConstraints() {
        self.authorViewSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.authorViewSkeleton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.authorViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.authorViewInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.authorViewInsets.right)
        }

        self.introVideoViewSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.introVideoViewSkeleton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.introVideoViewHeight)
            make.top
                .equalTo(self.authorViewSkeleton.snp.bottom)
                .offset(self.appearance.introVideoViewOffsetTop)
        }

        self.makeConstraintsForTextBlockView(
            headerView: self.aboutHeaderViewSkeleton,
            messageView: self.aboutMessageLabelSkeleton,
            headerTopPinView: self.introVideoViewSkeleton,
            headerViewInsets: self.appearance.aboutHeaderViewInsets,
            messageViewInsets: self.appearance.aboutMessageLabelInsets
        )

        self.makeConstraintsForTextBlockView(
            headerView: self.requirementsHeaderViewSkeleton,
            messageView: self.requirementsMessageLabelSkeleton,
            headerTopPinView: self.aboutMessageLabelSkeleton,
            headerViewInsets: self.appearance.requirementsHeaderViewInsets,
            messageViewInsets: self.appearance.requirementsMessageLabelInsets
        )
    }

    private func makeConstraintsForTextBlockView(
        headerView: UIView,
        messageView: UIView,
        headerTopPinView: UIView,
        headerViewInsets: UIEdgeInsets,
        messageViewInsets: UIEdgeInsets
    ) {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(headerViewInsets.left)
            make.top.equalTo(headerTopPinView.snp.bottom).offset(headerViewInsets.top)
            make.trailing.equalToSuperview().offset(-headerViewInsets.right)
        }

        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(messageViewInsets.left)
            make.top.equalTo(headerView.snp.bottom).offset(messageViewInsets.top)
            make.trailing.equalToSuperview().offset(-messageViewInsets.right)
            make.height.equalTo(self.appearance.messageLabelsHeight)
        }
    }
}
