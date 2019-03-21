//
// CourseInfoTabInfoSkeletonView.swift
// stepik-ios
//
// Created by Ivan Magda on 11/7/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabInfoSkeletonView {
    struct Appearance {
        let labelCornerRadius: CGFloat = 5.0
        let nameLabelHeight: CGFloat = 14.0

        let blockSpacing: CGFloat = 20

        let iconSpacing = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let iconSize = CGSize(width: 12, height: 12)
    }
}

final class CourseInfoTabInfoSkeletonView: UIView {
    private static let blocksCount = 6
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.blockSpacing
        return stackView
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

    private func makeBlockView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        let iconView = UIView()
        iconView.layer.masksToBounds = true
        iconView.layer.cornerRadius = self.appearance.labelCornerRadius

        view.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.iconSize)
            make.leading.equalTo(self.appearance.iconSpacing.left)
            make.centerY.equalToSuperview()
        }

        let labelView = UIView()
        labelView.layer.masksToBounds = true
        labelView.layer.cornerRadius = self.appearance.labelCornerRadius

        view.addSubview(labelView)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview()
            make.height.equalTo(self.appearance.nameLabelHeight)
            make.leading.equalTo(iconView.snp.trailing).offset(self.appearance.iconSpacing.right)
            make.trailing.equalToSuperview().offset(-self.appearance.iconSpacing.right)
        }

        return view
    }
}

extension CourseInfoTabInfoSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)

        (0..<CourseInfoTabInfoSkeletonView.blocksCount).forEach { _ in
            let blockView = self.makeBlockView()
            self.stackView.addArrangedSubview(blockView)
        }
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.leading.bottom.equalToSuperview().priority(999)
        }
    }
}
