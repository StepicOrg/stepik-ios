//
//  CourseInfoHeaderSkeletonView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.12.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoHeaderSkeletonView {
    struct Appearance {
        let actionButtonHeight: CGFloat = 42.0
        let actionButtonWidthRatio: CGFloat = 0.55
        let actionButtonCornerRadius: CGFloat = 21

        let verticalSpacing: CGFloat = 20

        let coverImageViewSize = CGSize(width: 36, height: 36)
        let coverImageViewCornerRadius: CGFloat = 3
        let coverImageViewInsets = UIEdgeInsets(top: 18, left: 30, bottom: 14, right: 10)

        let titleLabelInsets = UIEdgeInsets(top: 18, left: 10, bottom: 14, right: 30)
        let titleCornerRadius: CGFloat = 5
        let titleHeight: CGFloat = 13
        let titleSpacing: CGFloat = 6
        let subtitleWidthRatio: CGFloat = 0.45

        let statsViewHeight: CGFloat = 13.0
        let statsViewWidthRatio: CGFloat = 0.4
    }
}

final class CourseInfoHeaderSkeletonView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.coverImageViewCornerRadius
        return view
    }()

    private lazy var titleView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.titleCornerRadius
        return view
    }()

    private lazy var subTitleView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.titleCornerRadius
        return view
    }()

    private lazy var statsView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.titleCornerRadius
        return view
    }()

    private lazy var actionButtonView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.actionButtonCornerRadius
        return view
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseInfoHeaderSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleView)
        self.addSubview(self.subTitleView)
        self.addSubview(self.actionButtonView)
        self.addSubview(self.statsView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.coverImageViewSize)
            make.bottom.equalToSuperview().offset(-self.appearance.titleLabelInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.coverImageViewInsets.left)
        }

        self.titleView.translatesAutoresizingMaskIntoConstraints = false
        self.titleView.snp.makeConstraints { make in
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.titleLabelInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.titleLabelInsets.right)
            make.leading
                .equalTo(self.imageView.snp.trailing)
                .offset(self.appearance.titleLabelInsets.left)
            make.top.equalTo(self.imageView.snp.top)
            make.height.equalTo(self.appearance.titleHeight)
        }

        self.subTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.subTitleView.snp.makeConstraints { make in
            make.leading.equalTo(self.titleView.snp.leading)
            make.top.equalTo(self.titleView.snp.bottom).offset(self.appearance.titleSpacing)
            make.width.equalTo(self.titleView).multipliedBy(self.appearance.subtitleWidthRatio)
            make.height.equalTo(self.appearance.titleHeight)
        }

        self.statsView.translatesAutoresizingMaskIntoConstraints = false
        self.statsView.snp.makeConstraints { make in
            make.bottom
                .equalTo(self.titleView.snp.top)
                .offset(-self.appearance.verticalSpacing)
            make.centerX.equalToSuperview()
            make.height.equalTo(self.appearance.statsViewHeight)
            make.width
                .equalTo(self.snp.width)
                .multipliedBy(self.appearance.statsViewWidthRatio)
        }

        self.actionButtonView.translatesAutoresizingMaskIntoConstraints = false
        self.actionButtonView.snp.makeConstraints { make in
            make.bottom
                .equalTo(self.statsView.snp.top)
                .offset(-self.appearance.verticalSpacing)
            make.centerX.equalToSuperview()
            make.height.equalTo(self.appearance.actionButtonHeight)
            make.width
                .equalTo(self.snp.width)
                .multipliedBy(self.appearance.actionButtonWidthRatio)
        }
    }
}
