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

        let blockInsets = UIEdgeInsets(top: 40, left: 20, bottom: 0, right: 47)
        let innerInsets = UIEdgeInsets(top: 20, left: 47, bottom: 0, right: 47)

        let authorViewInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 47)

        let introVideoViewHeight: CGFloat = 203
    }
}

final class CourseInfoTabInfoSkeletonView: UIView {
    private let appearance: Appearance
    private let countInstructors: Int

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

    private lazy var targetAudienceHeaderViewSkeleton: UIView = {
        CourseInfoTabInfoBlockSkeletonView(
            appearance: .init(titleLabelCornerRadius: self.appearance.labelsCornerRadius)
        )
    }()
    private lazy var targetAudienceMessageLabelSkeleton = UIView()

    private lazy var instructorsHeaderViewSkeleton: UIView = {
        CourseInfoTabInfoBlockSkeletonView(
            appearance: .init(titleLabelCornerRadius: self.appearance.labelsCornerRadius)
        )
    }()

    private lazy var timeToCompleteHeaderViewSkeleton: UIView = {
        CourseInfoTabInfoBlockSkeletonView(
            appearance: .init(titleLabelCornerRadius: self.appearance.labelsCornerRadius)
        )
    }()
    private lazy var timeToCompleteMessageLabelSkeleton = UIView()

    private lazy var languageHeaderViewSkeleton: UIView = {
        CourseInfoTabInfoBlockSkeletonView(
            appearance: .init(titleLabelCornerRadius: self.appearance.labelsCornerRadius)
        )
    }()
    private lazy var languageMessageLabelSkeleton = UIView()

    private lazy var certificateHeaderViewSkeleton: UIView = {
        CourseInfoTabInfoBlockSkeletonView(
            appearance: .init(titleLabelCornerRadius: self.appearance.labelsCornerRadius)
        )
    }()
    private lazy var certificateMessageLabelSkeleton = UIView()

    private lazy var certificateDetailsHeaderViewSkeleton: UIView = {
        CourseInfoTabInfoBlockSkeletonView(
            appearance: .init(titleLabelCornerRadius: self.appearance.labelsCornerRadius)
        )
    }()
    private lazy var certificateDetailsMessageLabelSkeleton = UIView()

    // MARK: Init

    init(frame: CGRect = .zero, appearance: Appearance = Appearance(), countInstructors: Int = 2) {
        self.appearance = appearance
        self.countInstructors = min(countInstructors, 2)
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
                self.requirementsMessageLabelSkeleton,
                self.targetAudienceMessageLabelSkeleton,
                self.timeToCompleteMessageLabelSkeleton,
                self.languageMessageLabelSkeleton,
                self.certificateMessageLabelSkeleton,
                self.certificateDetailsMessageLabelSkeleton
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

        self.addSubview(self.targetAudienceHeaderViewSkeleton)
        self.addSubview(self.targetAudienceMessageLabelSkeleton)

        self.addSubview(self.instructorsHeaderViewSkeleton)

        self.addSubview(self.timeToCompleteHeaderViewSkeleton)
        self.addSubview(self.timeToCompleteMessageLabelSkeleton)

        self.addSubview(self.languageHeaderViewSkeleton)
        self.addSubview(self.languageMessageLabelSkeleton)

        self.addSubview(self.certificateHeaderViewSkeleton)
        self.addSubview(self.certificateMessageLabelSkeleton)

        self.addSubview(self.certificateDetailsHeaderViewSkeleton)
        self.addSubview(self.certificateDetailsMessageLabelSkeleton)
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
                .offset(self.appearance.innerInsets.top)
        }

        self.makeConstraintsForTextBlockView(
            headerView: self.aboutHeaderViewSkeleton,
            messageView: self.aboutMessageLabelSkeleton,
            headerTopPinView: self.introVideoViewSkeleton
        )

        self.makeConstraintsForTextBlockView(
            headerView: self.requirementsHeaderViewSkeleton,
            messageView: self.requirementsMessageLabelSkeleton,
            headerTopPinView: self.aboutMessageLabelSkeleton
        )

        self.makeConstraintsForTextBlockView(
            headerView: self.targetAudienceHeaderViewSkeleton,
            messageView: self.targetAudienceMessageLabelSkeleton,
            headerTopPinView: self.requirementsMessageLabelSkeleton
        )

        self.instructorsHeaderViewSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.instructorsHeaderViewSkeleton.snp.makeConstraints { make in
            make.leading
                .equalToSuperview()
                .offset(self.appearance.blockInsets.left)
            make.trailing
                .equalToSuperview()
                .offset(-self.appearance.blockInsets.right)
            make.top
                .equalTo(self.targetAudienceMessageLabelSkeleton.snp.bottom)
                .offset(self.appearance.blockInsets.top)
        }

        let lastInstructorView = self.addInstructorSkeletonViews()[self.countInstructors - 1]

        self.makeConstraintsForTextBlockView(
            headerView: self.timeToCompleteHeaderViewSkeleton,
            messageView: self.timeToCompleteMessageLabelSkeleton,
            headerTopPinView: lastInstructorView
        )

        self.makeConstraintsForTextBlockView(
            headerView: self.languageHeaderViewSkeleton,
            messageView: self.languageMessageLabelSkeleton,
            headerTopPinView: self.timeToCompleteMessageLabelSkeleton
        )

        self.makeConstraintsForTextBlockView(
            headerView: self.certificateHeaderViewSkeleton,
            messageView: self.certificateMessageLabelSkeleton,
            headerTopPinView: self.languageMessageLabelSkeleton
        )

        self.makeConstraintsForTextBlockView(
            headerView: self.certificateDetailsHeaderViewSkeleton,
            messageView: self.certificateDetailsMessageLabelSkeleton,
            headerTopPinView: self.certificateMessageLabelSkeleton
        )
    }

    // MARK: Private Helpers

    private func makeConstraintsForTextBlockView(
        headerView: UIView,
        messageView: UIView,
        headerTopPinView: UIView
    ) {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.blockInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.blockInsets.right)
            make.top
                .equalTo(headerTopPinView.snp.bottom)
                .offset(self.appearance.blockInsets.top)
        }

        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.innerInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.innerInsets.right)
            make.height.equalTo(self.appearance.messageLabelsHeight)
            make.top
                .equalTo(headerView.snp.bottom)
                .offset(self.appearance.innerInsets.top)
        }
    }

    private func addInstructorSkeletonViews() -> [UIView] {
        var instructors = [UIView]()
        var previous: UIView?

        for i in 0..<self.countInstructors {
            let isFirst = i == 0

            let instructorSkeletonView = CourseInfoTabInfoInstructorSkeletonView(
                appearance: .init(labelsCornerRadius: self.appearance.labelsCornerRadius)
            )
            self.addSubview(instructorSkeletonView)

            instructorSkeletonView.translatesAutoresizingMaskIntoConstraints = false
            instructorSkeletonView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(self.appearance.innerInsets.left)
                make.trailing.equalToSuperview().offset(-self.appearance.innerInsets.right)

                if isFirst {
                    make.top
                        .equalTo(self.instructorsHeaderViewSkeleton.snp.bottom)
                        .offset(self.appearance.innerInsets.top)
                }

                if let previous = previous {
                    make.top
                        .equalTo(previous.snp.bottom)
                        .offset(self.appearance.innerInsets.top)
                }
            }

            previous = instructorSkeletonView
            instructors.append(instructorSkeletonView)
        }

        return instructors
    }
}
