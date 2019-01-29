//
//  SyllabusUnitSkeletonView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabSyllabusCellSkeletonView {
    struct Appearance {
        let coverImageViewInsets = UIEdgeInsets(top: 20, left: 23, bottom: 20, right: 0)
        let coverImageViewSize = CGSize(width: 30, height: 30)
        let coverImageViewCornerRadius: CGFloat = 4.0

        let titleLabelHeight: CGFloat = 15
        let titleLabelCornerRadius: CGFloat = 5
        let titleLabelInsets = UIEdgeInsets(top: 22, left: 12, bottom: 0, right: 20)
    }
}

final class CourseInfoTabSyllabusCellSkeletonView: UIView {
    let appearance: Appearance

    private lazy var coverImageView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = self.appearance.coverImageViewCornerRadius
        return view
    }()

    private lazy var titleLabelView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = self.appearance.titleLabelCornerRadius
        return view
    }()

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

extension CourseInfoTabSyllabusCellSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.coverImageView)
        self.addSubview(self.titleLabelView)
    }

    func makeConstraints() {
        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.coverImageViewInsets.top)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.coverImageViewInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.coverImageViewInsets.left)
            make.size.equalTo(self.appearance.coverImageViewSize)
        }

        self.titleLabelView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabelView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.titleLabelHeight)
            make.leading
                .equalTo(self.coverImageView.snp.trailing)
                .offset(self.appearance.titleLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleLabelInsets.right)
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
