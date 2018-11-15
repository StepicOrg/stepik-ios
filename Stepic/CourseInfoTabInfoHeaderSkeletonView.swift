//
// CourseInfoTabInfoHeaderSkeletonView.swift
// stepik-ios
//
// Created by Ivan Magda on 11/9/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabInfoHeaderSkeletonView {
    struct Appearance {
        let imageViewSize = CGSize(width: 12, height: 12)
        let imageViewCornerRadius: CGFloat = 1

        let titleLabelHeight: CGFloat = 17
        let titleLabelLeadingOffset: CGFloat = 27
        var titleLabelCornerRadius: CGFloat = 1
    }
}

final class CourseInfoTabInfoHeaderSkeletonView: UIView {
    private let appearance: Appearance

    private lazy var imageViewSkeleton: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.imageViewCornerRadius
        return view
    }()

    private lazy var titleLabelSkeleton: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.titleLabelCornerRadius
        return view
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
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

extension CourseInfoTabInfoHeaderSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.imageViewSkeleton)
        self.addSubview(self.titleLabelSkeleton)
    }

    func makeConstraints() {
        self.imageViewSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.imageViewSkeleton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.size.equalTo(self.appearance.imageViewSize)
            make.centerY.equalTo(self.titleLabelSkeleton.snp.centerY)
        }

        self.titleLabelSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabelSkeleton.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.titleLabelHeight)
            make.leading
                .equalToSuperview()
                .offset(self.appearance.titleLabelLeadingOffset)
        }
    }
}
