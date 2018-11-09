//
//  CourseInfoInstructorView.swift
//  Stepic
//
//  Created by Ivan Magda on 11/2/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoInstructorView {
    struct Appearance {
        let imageViewSize = CGSize(width: 30, height: 30)
        let imageViewCornerRadius: CGFloat = 5

        let titleLabelInsets = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
        let titleLabelFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let titleLabelTextColor = UIColor.black

        let descriptionLabelInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        let descriptionLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let descriptionLabelTextColor = UIColor(hex: 0x535366)
    }
}

final class CourseInfoInstructorView: UIView {
    private let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = self.appearance.imageViewCornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = self.appearance.descriptionLabelFont
        label.textColor = self.appearance.descriptionLabelTextColor
        return label
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        viewModel: CourseInfoInstructorViewModel
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

        self.configure(with: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(with viewModel: CourseInfoInstructorViewModel) {
        self.imageView.image = viewModel.avatar
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
    }
}

extension CourseInfoInstructorView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.descriptionLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.imageViewSize)
            make.leading.top.equalToSuperview()
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.titleLabelInsets.left)
            make.centerY.equalTo(self.imageView.snp.centerY)
            make.trailing.equalToSuperview()
        }

        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.imageView.snp.leading)
            make.top.equalTo(self.imageView.snp.bottom).offset(self.appearance.descriptionLabelInsets.top)
            make.trailing.bottom.equalToSuperview()
        }
    }
}
