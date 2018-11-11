//
// Created by Ivan Magda on 11/9/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabInfoBlockSkeletonView {
    struct Appearance {
        let imageViewSize = CGSize(width: 12, height: 12)
        let imageViewCornerRadius: CGFloat = 1

        let titleLabelHeight: CGFloat = 17
        let titleLabelLeadingOffset: CGFloat = 27
        var titleLabelCornerRadius: CGFloat = 1
    }
}

final class CourseInfoTabInfoBlockSkeletonView: UIView {
    let appearance: Appearance

    private lazy var imageViewSkeleton = UIView()
    private lazy var titleLabelSkeleton = UIView()

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

extension CourseInfoTabInfoBlockSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.imageViewSkeleton.clipsToBounds = true
        self.imageViewSkeleton.layer.cornerRadius = self.appearance.imageViewCornerRadius

        self.titleLabelSkeleton.clipsToBounds = true
        self.titleLabelSkeleton.layer.cornerRadius = self.appearance.titleLabelCornerRadius
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
