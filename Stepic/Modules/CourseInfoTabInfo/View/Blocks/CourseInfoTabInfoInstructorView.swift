//
// CourseInfoTabInfoInstructorView.swift
// stepik-ios
//
//  Created by Ivan Magda on 11/2/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit
import Nuke

extension CourseInfoTabInfoInstructorView {
    struct Appearance {
        let imageFadeInDuration: TimeInterval = 0.15
        let imageViewSize = CGSize(width: 30, height: 30)
        let imageViewCornerRadius: CGFloat = 5

        let titleLabelInsets = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
        let titleLabelFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let titleLabelTextColor = UIColor.mainDark

        let descriptionLabelInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        let descriptionLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let descriptionLabelTextColor = UIColor.mainDark
    }
}

final class CourseInfoTabInfoInstructorView: UIView {
    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var summary: String? {
        didSet {
            self.descriptionLabel.text = self.summary
            self.updateDescriptionLabelTopConstraint()
        }
    }

    var avatarImageURL: URL? {
        didSet {
            self.loadImage(url: self.avatarImageURL)
        }
    }

    private let appearance: Appearance

    private var descriptionLabelTopConstraint: Constraint?

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = self.appearance.imageViewCornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.appearance.descriptionLabelFont
        label.textColor = self.appearance.descriptionLabelTextColor
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

    private func loadImage(url: URL?) {
        if let url = url {
            Nuke.loadImage(
                with: url,
                options: .init(
                    transition: .fadeIn(duration: self.appearance.imageFadeInDuration)
                ),
                into: self.imageView
            )
        } else {
            self.imageView.image = nil
        }
    }

    private func updateDescriptionLabelTopConstraint() {
        self.descriptionLabelTopConstraint?.update(
            offset: self.descriptionLabel.text?.isEmpty ?? true
                ? 0
                : self.appearance.descriptionLabelInsets.top
        )
    }
}

extension CourseInfoTabInfoInstructorView: ProgrammaticallyInitializableViewProtocol {
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
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.imageView.snp.centerY)
            make.leading
                .equalTo(self.imageView.snp.trailing)
                .offset(self.appearance.titleLabelInsets.left)
        }

        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.leading.equalTo(self.imageView.snp.leading)
            self.descriptionLabelTopConstraint = make.top
                .equalTo(self.imageView.snp.bottom)
                .offset(self.appearance.descriptionLabelInsets.top)
                .constraint
        }
    }
}
