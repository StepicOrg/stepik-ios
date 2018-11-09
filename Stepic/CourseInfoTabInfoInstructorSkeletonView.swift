//
// Created by Ivan Magda on 11/9/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabInfoInstructorSkeletonView {
    struct Appearance {
        var labelsCornerRadius: CGFloat = 2

        let imageViewCornerRadius: CGFloat = 5
        let imageViewSize = CGSize(width: 30, height: 30)

        let titleLabelHeight: CGFloat = 17
        let titleLabelOffsetLeading: CGFloat = 17

        let descriptionLabelOffsetTop: CGFloat = 10
        let descriptionLabelHeight: CGFloat = 80
    }
}

final class CourseInfoTabInfoInstructorSkeletonView: UIView {
    private let appearance: Appearance

    private lazy var imageViewSkeleton = UIView()
    private lazy var titleLabelSkeleton = UIView()
    private lazy var descriptionLabelSkeleton = UIView()

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

extension CourseInfoTabInfoInstructorSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.imageViewSkeleton.clipsToBounds = true
        self.imageViewSkeleton.layer.cornerRadius = self.appearance.imageViewCornerRadius

        self.titleLabelSkeleton.clipsToBounds = true
        self.titleLabelSkeleton.layer.cornerRadius = self.appearance.labelsCornerRadius

        self.descriptionLabelSkeleton.clipsToBounds = true
        self.descriptionLabelSkeleton.layer.cornerRadius = self.appearance.labelsCornerRadius
    }

    func addSubviews() {
        self.addSubview(self.imageViewSkeleton)
        self.addSubview(self.titleLabelSkeleton)
        self.addSubview(self.descriptionLabelSkeleton)
    }

    func makeConstraints() {
        self.imageViewSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.imageViewSkeleton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.imageViewSize)
            make.leading.top.equalToSuperview()
        }

        self.titleLabelSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabelSkeleton.snp.makeConstraints { make in
            make.centerY.equalTo(self.imageViewSkeleton.snp.centerY)
            make.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.titleLabelHeight)
            make.leading
                .equalTo(self.imageViewSkeleton.snp.trailing)
                .offset(self.appearance.titleLabelOffsetLeading)
        }

        self.descriptionLabelSkeleton.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabelSkeleton.snp.makeConstraints { make in
            make.leading.equalTo(self.imageViewSkeleton.snp.leading)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.descriptionLabelHeight)
            make.top
                .equalTo(self.imageViewSkeleton.snp.bottom)
                .offset(self.appearance.descriptionLabelOffsetTop)
        }
    }
}
