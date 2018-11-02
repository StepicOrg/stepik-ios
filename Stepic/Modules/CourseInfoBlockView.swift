//
//  CourseInfoBlockView.swift
//  Stepic
//
//  Created by Ivan Magda on 11/1/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoBlockView {
    struct Appearance {
        let imageViewSize = CGSize(width: 12, height: 12)

        let titleLabelFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let titleLabelTextColor = UIColor.black
        let titleLabelLeadingSpace: CGFloat = 12
    }
}

final class CourseInfoBlockView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = self.appearance.titleLabelFont
        label.textColor = appearance.titleLabelTextColor
        return label
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        viewModel: CourseInfoBlockViewModelProtocol? = nil
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

        if let viewModel = viewModel {
            self.configure(with: viewModel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: CourseInfoBlockViewModelProtocol) {
        self.imageView.image = viewModel.image
        self.titleLabel.text = viewModel.title
    }
}

extension CourseInfoBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.imageViewSize.height)
            make.width.equalTo(self.appearance.imageViewSize.width)
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.titleLabelLeadingSpace)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
