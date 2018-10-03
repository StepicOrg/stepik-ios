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
        var imagesRenderingBackgroundColor = UIColor(hex: 0x535366)
        var imagesRenderingTintColor = UIColor(hex: 0x89cc89)

        var itemTextColor = UIColor.white
        var itemImageTintColor = UIColor.white
    }
}

final class CourseWidgetStatsView: UIView {
    let appearance: Appearance

    var learnersLabelText: String? {
        didSet {
            self.learnersView.text = self.learnersLabelText
        }
    }

    var ratingLabelText: String? {
        didSet {
            self.ratingView.isHidden = self.ratingLabelText == nil
            self.ratingView.text = self.ratingLabelText
        }
    }

    var progress: CourseWidgetProgressViewModel? {
        didSet {
            guard let progress = progress else {
                progressView.isHidden = true
                return
            }

            self.updateProgress(viewModel: progress)
        }
    }

    private lazy var learnersView: CourseWidgetStatsItemView = {
        let appearance = CourseWidgetStatsItemView.Appearance(
            imageViewSize: self.appearance.learnersViewImageViewSize,
            imageTintColor: self.appearance.itemImageTintColor,
            textColor: self.appearance.itemTextColor
        )
        let view = CourseWidgetStatsItemView(
            frame: .zero,
            appearance: appearance
        )
        view.image = UIImage(named: "course-widget-user")!.withRenderingMode(.alwaysTemplate)
        return view
    }()

    private lazy var ratingView: CourseWidgetStatsItemView = {
        let appearance = CourseWidgetStatsItemView.Appearance(
            imageViewSize: self.appearance.ratingViewImageViewSize,
            imageTintColor: self.appearance.itemImageTintColor,
            textColor: self.appearance.itemTextColor
        )
        let view = CourseWidgetStatsItemView(
            frame: .zero,
            appearance: appearance
        )
        view.image = UIImage(named: "course-widget-rating")!.withRenderingMode(.alwaysTemplate)
        return view
    }()

    private lazy var progressView: CourseWidgetStatsItemView = {
        let appearance = CourseWidgetStatsItemView.Appearance(
            imageViewSize: self.appearance.progressViewImageViewSize,
            imageTintColor: .clear,
            textColor: self.appearance.itemTextColor
        )
        let view = CourseWidgetStatsItemView(
            frame: .zero,
            appearance: appearance
        )
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = self.appearance.statItemsSpacing
        return stackView
    }()

    init(frame: CGRect, appearance: Appearance = Appearance()) {
        self.appearance = appearance
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
            backgroundColor: self.appearance.imagesRenderingBackgroundColor,
            progressColor: self.appearance.imagesRenderingTintColor
        )

        if let pieImage = progressPie.uiImage {
            progressView.image = pieImage
            progressView.text = viewModel.progressLabelText
            progressView.isHidden = false
        }
    }
}

extension CourseWidgetStatsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.ratingView.isHidden = false
        self.progressView.isHidden = false
    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.learnersView)
        self.stackView.addArrangedSubview(self.ratingView)
        self.stackView.addArrangedSubview(self.progressView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.leftInset)
            make.centerY.equalToSuperview()
            make.top.bottom.trailing.greaterThanOrEqualToSuperview()
        }
    }
}
