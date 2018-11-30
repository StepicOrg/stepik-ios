//
//  CourseInfoTabSyllabusCellView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabSyllabusCellView {
    struct Appearance {
        let coverImageViewCornerRadius: CGFloat = 4
        let coverImageViewInsets = UIEdgeInsets(top: 20, left: 23, bottom: 0, right: 0)
        let coverImageViewSize = CGSize(width: 30, height: 30)

        let titleTextColor = UIColor.mainDark
        let titleFont = UIFont.systemFont(ofSize: 14)
        let titleLabelInsets = UIEdgeInsets(top: 18, left: 12, bottom: 7, right: 8)

        let downloadButtonInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        let downloadButtonSize = CGSize(width: 24, height: 24)

        let statsInsets = UIEdgeInsets(top: 11, left: 0, bottom: 16, right: 0)
        let statsViewHeight: CGFloat = 17.0

        let progressViewHeight: CGFloat = 3
        let progressViewMainColor = UIColor.stepicGreen
        let progressViewSecondaryColor = UIColor.clear
    }
}

final class CourseInfoTabSyllabusCellView: UIView {
    let appearance: Appearance

    private lazy var coverImageView: CourseCoverImageView = {
        let view = CourseCoverImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.coverImageViewCornerRadius
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 2

        label.text = "1.2 Second Lesson More Detailed and Interesting Name"

        return label
    }()

    private lazy var downloadButton: DownloadControlView = {
        let view = DownloadControlView(initialState: .readyToDownloading)
        return view
    }()

    private lazy var statsView: CourseInfoTabSyllabusCellStatsView = {
        // For test
        let view = CourseInfoTabSyllabusCellStatsView()
        view.learnersLabelText = "655"
        view.progressLabelText = "8/10"
        view.likesCount = -1
        return view
    }()

    private lazy var progressIndicatorView: UIProgressView = {
        let view = UIProgressView()
        view.progressViewStyle = .bar
        view.trackTintColor = self.appearance.progressViewSecondaryColor
        view.progressTintColor = self.appearance.progressViewMainColor
        view.transform = CGAffineTransform(rotationAngle: .pi / -2)

        view.progress = 0.7

        return view
    }()

    // To use rotated view w/ auto-layout
    private lazy var progressIndicatorViewContainerView = UIView()

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

extension CourseInfoTabSyllabusCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.downloadButton)
        self.addSubview(self.coverImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.statsView)

        self.progressIndicatorViewContainerView.addSubview(self.progressIndicatorView)
        self.addSubview(self.progressIndicatorViewContainerView)
    }

    func makeConstraints() {
        self.downloadButton.translatesAutoresizingMaskIntoConstraints = false
        self.downloadButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.downloadButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.downloadButtonSize)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-self.appearance.downloadButtonInsets.right)
        }

        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.coverImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.coverImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.coverImageViewSize)
            make.leading.equalToSuperview().offset(self.appearance.coverImageViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.coverImageViewInsets.top)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading
                .equalTo(self.coverImageView.snp.trailing)
                .offset(self.appearance.titleLabelInsets.left)
            make.trailing
                .equalTo(self.downloadButton.snp.leading)
                .offset(-self.appearance.titleLabelInsets.left)
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.bottom.greaterThanOrEqualTo(self.coverImageView.snp.bottom)
        }

        self.statsView.translatesAutoresizingMaskIntoConstraints = false
        self.statsView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.statsView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.statsViewHeight)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.trailing.lessThanOrEqualTo(self.titleLabel.snp.trailing)
            make.top
                .equalTo(self.coverImageView.snp.bottom)
                .offset(self.appearance.statsInsets.top)
            make.bottom
                .equalToSuperview()
                .offset(-self.appearance.statsInsets.bottom)
        }

        self.progressIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.progressIndicatorView.snp.makeConstraints { make in
            make.width.equalTo(self.progressIndicatorViewContainerView.snp.height)
            make.height.equalTo(self.appearance.progressViewHeight)
            make.centerY.centerX.equalToSuperview()
        }

        self.progressIndicatorViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.progressIndicatorViewContainerView.snp.makeConstraints { make in
            make.leading.height.bottom.equalToSuperview()
            make.width.equalTo(self.progressIndicatorView.snp.height)
        }
    }
}
