//
//  CourseWidgetView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseWidgetView {
    struct Appearance {
        let coverViewWidthHeight: CGFloat = 80.0

        let secondaryActionButtonInsets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 9)
        let secondaryActionButtonSize = CGSize(width: 80, height: 48)

        let mainActionButtonHeight: CGFloat = 48.0

        let statsViewHeight: CGFloat = 17
        let statsViewInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 9, bottom: 12, right: 0)
    }
}

final class CourseWidgetView: UIView {
    let appearance: Appearance

    var colorMode: CourseWidgetColorMode {
        didSet {
            self.updateColors()
        }
    }

    private lazy var coverView: CourseWidgetCoverView = CourseWidgetCoverView(frame: .zero)
    private lazy var primaryActionButton: CourseWidgetButton = CourseWidgetButton()
    private lazy var secondaryActionButton: CourseWidgetButton = CourseWidgetButton()
    private lazy var titleLabel: CourseWidgetLabel = CourseWidgetLabel(frame: .zero)
    private lazy var statsView: CourseWidgetStatsView = CourseWidgetStatsView(frame: .zero)

    init(
        frame: CGRect,
        colorMode: CourseWidgetColorMode = .default,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.colorMode = colorMode
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CourseWidgetViewModel) {
        self.titleLabel.text = viewModel.title
        self.coverView.coverImageURL = viewModel.coverImageURL
        self.coverView.shouldShowAdaptiveMark = viewModel.isAdaptive

        self.primaryActionButton.setTitle(
            viewModel.primaryButtonDescription.title,
            for: .normal
        )
        self.primaryActionButton.isCallToAction = viewModel
            .primaryButtonDescription
            .isCallToAction

        self.secondaryActionButton.setTitle(
            viewModel.secondaryButtonDescription.title,
            for: .normal
        )
        self.secondaryActionButton.isCallToAction = viewModel
            .secondaryButtonDescription
            .isCallToAction

        self.statsView.learnersLabelText = viewModel.learnersLabelText
        self.statsView.ratingLabelText = viewModel.ratingLabelText
        self.statsView.progress = viewModel.progress
    }

    func updateProgress(viewModel: CourseWidgetProgressViewModel) {
        self.statsView.progress = viewModel
    }

    private func updateColors() {
        self.primaryActionButton.colorMode = self.colorMode
        self.secondaryActionButton.colorMode = self.colorMode
        self.titleLabel.colorMode = self.colorMode
        self.statsView.colorMode = self.colorMode
    }
}

extension CourseWidgetView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateColors()
    }

    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.primaryActionButton)
        self.addSubview(self.secondaryActionButton)
        self.addSubview(self.titleLabel)
        self.addSubview(self.statsView)
    }

    func makeConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.height.width.equalTo(self.appearance.coverViewWidthHeight)
        }

        self.primaryActionButton.translatesAutoresizingMaskIntoConstraints = false
        self.primaryActionButton.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.mainActionButtonHeight)
        }

        self.secondaryActionButton.translatesAutoresizingMaskIntoConstraints = false
        self.secondaryActionButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.secondaryActionButtonSize)
            make.leading.bottom.equalToSuperview()
            make.top
                .equalTo(self.coverView.snp.bottom)
                .offset(self.appearance.secondaryActionButtonInsets.top)
            make.trailing
                .equalTo(self.primaryActionButton.snp.leading)
                .offset(-self.appearance.secondaryActionButtonInsets.right)
        }

        self.statsView.translatesAutoresizingMaskIntoConstraints = false
        self.statsView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom
                .lessThanOrEqualTo(self.primaryActionButton.snp.top)
                .offset(-self.appearance.statsViewInsets.bottom)
            make.leading
                .equalTo(self.coverView.snp.trailing)
                .offset(self.appearance.statsViewInsets.left)
            make.height.equalTo(self.appearance.statsViewHeight)
            make.top
                .equalTo(self.titleLabel.snp.bottom)
                .offset(self.appearance.statsViewInsets.top)
                .priority(.low)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(self.statsView.snp.leading)
        }
    }
}
