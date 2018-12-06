//
//  CourseInfoTabSyllabusSectionView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 19/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabSyllabusSectionView {
    struct Appearance {
        let backgroundColor = UIColor(hex: 0xf6f6f6)

        let indexTextColor = UIColor.mainDark
        let indexFont = UIFont.systemFont(ofSize: 16)
        let indexLabelInsets = UIEdgeInsets(top: 18, left: 18, bottom: 0, right: 15)

        let titleTextColor = UIColor.mainDark
        let titleFont = UIFont.systemFont(ofSize: 14)
        let titleLabelInsets = UIEdgeInsets(top: 19, left: 15, bottom: 0, right: 15)

        let downloadButtonInsets = UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 16)
        let downloadButtonSize = CGSize(width: 24, height: 24)

        let deadlinesInsets = UIEdgeInsets(top: 14, left: 0, bottom: 16, right: 0)

        let progressViewHeight: CGFloat = 3
        let progressViewMainColor = UIColor.stepicGreen
        let progressViewSecondaryColor = UIColor.clear
    }
}

final class CourseInfoTabSyllabusSectionView: UIView {
    let appearance: Appearance

    private lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.indexFont
        label.textColor = self.appearance.indexTextColor

        label.text = "1"

        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 2

        label.text = "Introduction to JavaScript JavaScript JavaScript JavaScript JavaScript JavaScript JavaScript JavaScript"

        return label
    }()

    private lazy var downloadButton: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
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

    private lazy var deadlinesView = CourseInfoTabSyllabusSectionDeadlinesView(
        items: [
            CourseInfoTabSyllabusSectionDeadlinesView.Item(text: "Start date\n18 October 2018 00:00 ", progressBefore: 1.0, isCompleted: true),
            CourseInfoTabSyllabusSectionDeadlinesView.Item(text: "Soft deadline\n18 October 2018 00:00 ", progressBefore: 1.0, isCompleted: true),
            CourseInfoTabSyllabusSectionDeadlinesView.Item(text: "Hard deadline\n18 October 2018 00:00 ", progressBefore: 0.7, isCompleted: false),
            CourseInfoTabSyllabusSectionDeadlinesView.Item(text: "End date\n18 October 2018 00:00 ", progressBefore: 0.0, isCompleted: false)
        ]
    )

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

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension CourseInfoTabSyllabusSectionView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.indexLabel)
        self.addSubview(self.titleLabel)
        self.addSubview(self.downloadButton)
        self.addSubview(self.deadlinesView)

        self.addSubview(self.progressIndicatorViewContainerView)
        self.progressIndicatorViewContainerView.addSubview(self.progressIndicatorView)
    }

    func makeConstraints() {
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

        self.downloadButton.translatesAutoresizingMaskIntoConstraints = false
        self.downloadButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.downloadButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.downloadButtonSize)
            make.top.equalToSuperview().offset(self.appearance.downloadButtonInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.downloadButtonInsets.right)
        }

        self.indexLabel.translatesAutoresizingMaskIntoConstraints = false
        self.indexLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.indexLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.indexLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.indexLabelInsets.left)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.leading
                .equalTo(self.indexLabel.snp.trailing)
                .offset(self.appearance.titleLabelInsets.left)
            make.trailing
                .equalTo(self.downloadButton.snp.leading)
                .offset(-self.appearance.titleLabelInsets.right)
        }

        self.deadlinesView.translatesAutoresizingMaskIntoConstraints = false
        self.deadlinesView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top
                .greaterThanOrEqualTo(self.downloadButton.snp.bottom)
                .offset(self.appearance.deadlinesInsets.top)
            make.top
                .greaterThanOrEqualTo(self.titleLabel.snp.bottom)
                .offset(self.appearance.deadlinesInsets.top)
            make.bottom
                .equalToSuperview()
                .offset(-self.appearance.deadlinesInsets.bottom)
                .priority(.medium)
        }
    }
}
