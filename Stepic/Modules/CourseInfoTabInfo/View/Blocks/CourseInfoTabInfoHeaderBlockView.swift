//
// CourseInfoTabInfoHeaderBlockView.swift
// stepik-ios
//
//  Created by Ivan Magda on 11/1/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabInfoHeaderBlockView {
    struct Appearance {
        let imageViewSize = CGSize(width: 12, height: 12)
        let imageViewTintColor = UIColor.mainDark

        let titleLabelFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let titleLabelTextColor = UIColor.mainDark
        let titleLabelLeadingSpace: CGFloat = 27
    }
}

final class CourseInfoTabInfoHeaderBlockView: UIView {
    var icon: UIImage? {
        didSet {
            self.iconImageView.image = self.icon?.withRenderingMode(.alwaysTemplate)
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    private let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.imageViewTintColor
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        return label
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

extension CourseInfoTabInfoHeaderBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.imageViewSize.height)
            make.width.equalTo(self.appearance.imageViewSize.width)
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.titleLabelLeadingSpace)
            make.top.trailing.bottom.equalToSuperview()
        }
    }
}
