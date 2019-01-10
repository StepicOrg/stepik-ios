//
//  CourseInfoStatsView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 02.11.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit
import Nuke

extension CourseInfoStatsView {
    struct Appearance {
        let itemsSpacing: CGFloat = 17.0

        let itemTextFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let itemTextColor = UIColor.white

        let learnersImageColor = UIColor.white
        let learnersImageSize = CGSize(width: 8.5, height: 11)
        let learnersSpacing: CGFloat = 5.0

        let progressViewImageSize = CGSize(width: 11, height: 11)

        let imagesRenderingSize = CGSize(width: 30, height: 30)
        let imagesRenderingLineWidth: CGFloat = 6.0
        var imagesRenderingBackgroundColor = UIColor.white
        var imagesRenderingTintColor = UIColor(hex: 0x89cc89)
    }
}

final class CourseInfoStatsView: UIView {
    let appearance: Appearance
    private static let maxStarsCount = 5

    private lazy var itemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.itemsSpacing
        return stackView
    }()

    private lazy var ratingContainerView = UIView()
    private lazy var ratingView = CourseRatingView()

    private lazy var learnersView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        appearance.iconSpacing = self.appearance.learnersSpacing
        appearance.imageViewSize = self.appearance.learnersImageSize
        appearance.imageTintColor = self.appearance.learnersImageColor
        appearance.textColor = self.appearance.itemTextColor
        appearance.font = self.appearance.itemTextFont
        let view = CourseWidgetStatsItemView(appearance: appearance)
        view.image = UIImage(named: "course-widget-user")!
            .withRenderingMode(.alwaysTemplate)
        return view
    }()

    private lazy var progressView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        appearance.imageViewSize = self.appearance.progressViewImageSize
        appearance.imageTintColor = .clear
        appearance.textColor = self.appearance.itemTextColor
        appearance.font = self.appearance.itemTextFont
        let view = CourseWidgetStatsItemView(appearance: appearance)
        return view
    }()

    var learnersLabelText: String? {
        didSet {
            self.learnersView.isHidden = self.learnersLabelText == nil
            self.learnersView.text = self.learnersLabelText
        }
    }

    var rating: Int? {
        didSet {
            self.ratingView.isHidden = self.rating == nil
            self.ratingView.starsCount = self.rating ?? 0
        }
    }

    var progress: CourseInfoProgressViewModel? {
        didSet {
            guard let progress = progress else {
                progressView.isHidden = true
                return
            }

            self.updateProgress(viewModel: progress)
        }
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateProgress(viewModel: CourseInfoProgressViewModel) {
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

extension CourseInfoStatsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.ratingView.isHidden = false
        self.progressView.isHidden = false
    }

    func addSubviews() {
        self.addSubview(self.itemsStackView)

        self.ratingContainerView.addSubview(self.ratingView)
        self.itemsStackView.addArrangedSubview(self.ratingContainerView)
        self.itemsStackView.addArrangedSubview(self.learnersView)
        self.itemsStackView.addArrangedSubview(self.progressView)
    }

    func makeConstraints() {
        self.ratingView.translatesAutoresizingMaskIntoConstraints = false
        self.ratingView.snp.makeConstraints { make in
            make.top.leading.greaterThanOrEqualToSuperview()
            make.trailing.bottom.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }

        self.itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.itemsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
