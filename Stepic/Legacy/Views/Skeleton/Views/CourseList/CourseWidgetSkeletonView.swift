//
//  CourseWidgetSkeletonView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 01.10.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

extension CourseWidgetSkeletonView {
    struct Appearance {
        let coverViewWidthHeight: CGFloat = 80.0

        let mainActionButtonHeight: CGFloat = 48.0

        let titleLabelHeight: CGFloat = 17
        let statsViewHeight: CGFloat = 17
        let titleLabelInsets = UIEdgeInsets(top: 3, left: 9, bottom: 8, right: 3)
        let statsViewInsets = UIEdgeInsets(top: 8, left: 9, bottom: 0, right: 20)

        let coverViewCornerRadius: CGFloat = 8
        let buttonsCornerRadius: CGFloat = 7
        let labelsCornerRadius: CGFloat = 5
    }
}

final class CourseWidgetSkeletonView: UIView {
    let appearance: Appearance

    private lazy var coverImageViewSkeleton = UIView()
    private lazy var primaryButtonSkeleton = UIView()
    private lazy var titleLabelSkeleton = UIView()
    private lazy var statsViewSkeleton = UIView()

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

extension CourseWidgetSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.coverImageViewSkeleton.clipsToBounds = true
        self.coverImageViewSkeleton.layer.cornerRadius = self.appearance.coverViewCornerRadius

        self.primaryButtonSkeleton.clipsToBounds = true
        self.primaryButtonSkeleton.layer.cornerRadius = self.appearance.buttonsCornerRadius

        self.titleLabelSkeleton.clipsToBounds = true
        self.titleLabelSkeleton.layer.cornerRadius = self.appearance.labelsCornerRadius

        self.statsViewSkeleton.clipsToBounds = true
        self.statsViewSkeleton.layer.cornerRadius = self.appearance.labelsCornerRadius
    }

    func addSubviews() {
        self.addSubview(self.coverImageViewSkeleton)
        self.addSubview(self.primaryButtonSkeleton)
        self.addSubview(self.titleLabelSkeleton)
        self.addSubview(self.statsViewSkeleton)
    }

    func makeConstraints() {
        self.coverImageViewSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageViewSkeleton.snp.makeConstraints { make in
            make.height.width.equalTo(self.appearance.coverViewWidthHeight)
            make.top.leading.equalToSuperview()
        }

        self.primaryButtonSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.primaryButtonSkeleton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.mainActionButtonHeight)
            make.leading.bottom.equalToSuperview()
            make.trailing.equalTo(self.titleLabelSkeleton.snp.trailing)
        }

        self.titleLabelSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabelSkeleton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.titleLabelHeight)
            make.leading
                .equalTo(self.coverImageViewSkeleton.snp.trailing)
                .offset(self.appearance.titleLabelInsets.left)
            make.top
                .equalToSuperview()
                .offset(self.appearance.titleLabelInsets.top)
            make.trailing
                .equalToSuperview()
                .offset(-self.appearance.titleLabelInsets.right)
        }

        self.statsViewSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.statsViewSkeleton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.statsViewHeight)
            make.leading
                .equalTo(self.coverImageViewSkeleton.snp.trailing)
                .offset(self.appearance.statsViewInsets.left)
            make.top
                .equalTo(self.titleLabelSkeleton.snp.bottom)
                .offset(self.appearance.statsViewInsets.top)
            make.trailing
                .equalToSuperview()
                .offset(-self.appearance.statsViewInsets.right)
        }
    }
}
