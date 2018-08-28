//
//  CourseWidgetStatsView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseWidgetStatsView {
    struct Appearance {
        let statItemsSpacing: CGFloat = 8
        let leftInset: CGFloat = 2.0

        let learnersViewImageViewSize = CGSize(width: 8, height: 10)
        let ratingViewImageViewSize = CGSize(width: 8, height: 12)
        let progressViewImageViewSize = CGSize(width: 12, height: 12)

        let imagesRenderingSize = CGSize(width: 30, height: 30)
        let imagesRenderingLineWidth: CGFloat = 6.0
        let lightModeImagesRenderingBackgroundColor = UIColor(hex: 0x535366)
        let lightModeImagesRenderingTintColor = UIColor(hex: 0x89cc89)
        let darkModeImagesRenderingBackgroundColor = UIColor.white
        let darkModeImagesRenderingTintColor = UIColor(hex: 0x89cc89)
    }
}

final class CourseWidgetStatsView: UIView {
    let appearance: Appearance

    var colorMode: CourseWidgetColorMode {
        didSet {
            self.updateColorMode()
        }
    }

    var learnersLabelText: String? {
        didSet {
            self.learnersView.text = self.learnersLabelText
        }
    }

    var ratingLabelText: String? {
        didSet {
            self.ratingView.text = self.ratingLabelText
        }
    }

    private lazy var learnersView: CourseWidgetStatsItemView = {
        let appearance = CourseWidgetStatsItemView.Appearance(
            imageViewSize: self.appearance.learnersViewImageViewSize
        )
        let view = CourseWidgetStatsItemView(
            frame: .zero,
            colorMode: self.colorMode,
            appearance: appearance
        )
        view.image = UIImage(named: "course-widget-user")!.withRenderingMode(.alwaysTemplate)
        return view
    }()

    private lazy var ratingView: CourseWidgetStatsItemView = {
        let appearance = CourseWidgetStatsItemView.Appearance(
            imageViewSize: self.appearance.ratingViewImageViewSize
        )
        let view = CourseWidgetStatsItemView(
            frame: .zero,
            colorMode: self.colorMode,
            appearance: appearance
        )
        view.image = UIImage(named: "course-widget-rating")!.withRenderingMode(.alwaysTemplate)
        return view
    }()

    private lazy var progressView: CourseWidgetStatsItemView = {
        let appearance = CourseWidgetStatsItemView.Appearance(
            imageViewSize: self.appearance.progressViewImageViewSize
        )
        let view = CourseWidgetStatsItemView(
            frame: .zero,
            colorMode: self.colorMode,
            appearance: appearance
        )
        return view
    }()

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

    func updateProgress(viewModel: CourseWidgetProgressViewModel) {
        let progressPie = ProgressCircleImage(
            progress: viewModel.progress,
            size: self.appearance.imagesRenderingSize,
            lineWidth: self.appearance.imagesRenderingLineWidth,
            backgroundColor: self.getImagesRenderingBackgroundColor(for: self.colorMode),
            progressColor: self.getImagesRenderingProgressColor(for: self.colorMode)
        )

        if let pieImage = progressPie.uiImage {
            progressView.image = pieImage
            progressView.text = viewModel.progressLabelText
            progressView.isHidden = false
        }
    }
}

// MARK: - Color mode

extension CourseWidgetStatsView {
    private func updateColorMode() {
        self.learnersView.colorMode = self.colorMode
        self.ratingView.colorMode = self.colorMode
        self.progressView.colorMode = self.colorMode

        self.learnersView.imageView.tintColor = self.getImagesRenderingBackgroundColor(
            for: self.colorMode
        )
        self.ratingView.imageView.tintColor = self.getImagesRenderingBackgroundColor(
            for: self.colorMode
        )
    }

    private func getImagesRenderingBackgroundColor(
        for colorMode: CourseWidgetColorMode
    ) -> UIColor {
        switch colorMode {
        case .light:
            return self.appearance.lightModeImagesRenderingBackgroundColor
        case .dark:
            return self.appearance.darkModeImagesRenderingBackgroundColor
        }
    }

    private func getImagesRenderingProgressColor(
        for colorMode: CourseWidgetColorMode
    ) -> UIColor {
        switch colorMode {
        case .light:
            return self.appearance.lightModeImagesRenderingTintColor
        case .dark:
            return self.appearance.darkModeImagesRenderingTintColor
        }
    }
}

extension CourseWidgetStatsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.progressView.isHidden = false
    }

    func addSubviews() {
        self.addSubview(learnersView)
        self.addSubview(ratingView)
        self.addSubview(progressView)
    }

    func makeConstraints() {
        self.learnersView.translatesAutoresizingMaskIntoConstraints = false
        self.learnersView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.leftInset)
            make.centerY.equalToSuperview()
            make.top.bottom.greaterThanOrEqualToSuperview()
        }

        self.ratingView.translatesAutoresizingMaskIntoConstraints = false
        self.ratingView.snp.makeConstraints { make in
            make.leading
                .equalTo(self.learnersView.snp.trailing)
                .offset(self.appearance.statItemsSpacing)
            make.centerY.equalToSuperview()
            make.top.bottom.greaterThanOrEqualToSuperview()
        }

        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.snp.makeConstraints { make in
            make.leading
                .equalTo(self.ratingView.snp.trailing)
                .offset(self.appearance.statItemsSpacing)
            make.centerY.equalToSuperview()
            make.top.bottom.trailing.greaterThanOrEqualToSuperview()
        }
    }
}
