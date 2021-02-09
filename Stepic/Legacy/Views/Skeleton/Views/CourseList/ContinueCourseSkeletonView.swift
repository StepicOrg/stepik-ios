//
//  ContinueCourseSkeletonView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 01.10.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

extension ContinueCourseSkeletonView {
    struct Appearance {
        let labelsCornerRadius: CGFloat = 5
        let defaultInsets = LayoutInsets.default

        let coverCornerRadius: CGFloat = 8
        let coverSize = CGSize(width: 40, height: 40)

        let courseLabelInsets = LayoutInsets(left: 8, right: 8)
        let courseLabelWidthRatio: CGFloat = 0.7

        let statsViewHeight: CGFloat = 17
        let statsViewWidthRatio: CGFloat = 0.4
    }
}

final class ContinueCourseSkeletonView: UIView {
    let appearance: Appearance

    private lazy var courseCoverView = UIView()
    private lazy var courseLabelView = UIView()
    private lazy var courseStatsView = UIView()

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

extension ContinueCourseSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.courseCoverView.clipsToBounds = true
        self.courseCoverView.layer.cornerRadius = self.appearance.coverCornerRadius

        self.courseLabelView.clipsToBounds = true
        self.courseLabelView.layer.cornerRadius = self.appearance.labelsCornerRadius

        self.courseStatsView.clipsToBounds = true
        self.courseStatsView.layer.cornerRadius = self.appearance.labelsCornerRadius
    }

    func addSubviews() {
        self.addSubviews([self.courseCoverView, self.courseLabelView, self.courseStatsView])
    }

    func makeConstraints() {
        self.courseCoverView.translatesAutoresizingMaskIntoConstraints = false
        self.courseCoverView.snp.makeConstraints { make in
            make.leading
                .equalTo(self.safeAreaLayoutGuide.snp.leading)
                .offset(self.appearance.defaultInsets.left)
            make.centerY.equalToSuperview()
            make.size.equalTo(self.appearance.coverSize)
        }

        self.courseLabelView.translatesAutoresizingMaskIntoConstraints = false
        self.courseLabelView.snp.makeConstraints { make in
            make.top.equalTo(self.courseCoverView.snp.top)
            make.leading
                .equalTo(self.courseCoverView.snp.trailing)
                .offset(self.appearance.courseLabelInsets.left)
            make.width.equalToSuperview().multipliedBy(self.appearance.courseLabelWidthRatio)
        }

        self.courseStatsView.translatesAutoresizingMaskIntoConstraints = false
        self.courseStatsView.snp.makeConstraints { make in
            make.leading.equalTo(self.courseLabelView.snp.leading)
            make.bottom.equalTo(self.courseCoverView.snp.bottom)
            make.height.equalTo(self.appearance.statsViewHeight)
            make.width.equalToSuperview().multipliedBy(self.appearance.statsViewWidthRatio)
        }
    }
}
