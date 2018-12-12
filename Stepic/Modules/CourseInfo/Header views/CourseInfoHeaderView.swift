//
//  CourseInfoHeaderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 01/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoHeaderView {
    struct Appearance {
        let actionButtonInsets = UIEdgeInsets(top: 10, left: 0, bottom: 15, right: 0)
        let actionButtonHeight: CGFloat = 42.0
        let actionButtonWidthRatio: CGFloat = 0.55

        let coverImageViewSize = CGSize(width: 36, height: 36)
        let coverImageViewCornerRadius: CGFloat = 3

        let titleLabelFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let titleLabelColor = UIColor.white

        let titleStackViewSpacing: CGFloat = 10
        let titleStackViewInsets = UIEdgeInsets(top: 18, left: 30, bottom: 16, right: 30)

        let marksStackViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
        let marksStackViewSpacing: CGFloat = 10.0

        let statsViewHeight: CGFloat = 17.0

        let verifiedTextColor = UIColor.white
        let verifiedImageSize = CGSize(width: 11, height: 11)
        let verifiedSpacing: CGFloat = 4.0
        let verifiedTextFont = UIFont.systemFont(ofSize: 12, weight: .light)
    }
}

final class CourseInfoHeaderView: UIView {
    let appearance: Appearance

    private lazy var backgroundView: CourseInfoBlurredBackgroundView = {
        let view = CourseInfoBlurredBackgroundView()
        // To prevent tap handling
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var actionButton: ContinueActionButton = {
        let button = ContinueActionButton(mode: .callToAction)
        button.setTitle(NSLocalizedString("WidgetButtonJoin", comment: ""), for: .normal)
        return button
    }()

    private lazy var coverImageView: CourseCoverImageView = {
        let view = CourseCoverImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.coverImageViewCornerRadius
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = self.appearance.titleLabelColor
        return label
    }()

    private lazy var verifiedSignView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        appearance.iconSpacing = self.appearance.verifiedSpacing
        appearance.imageViewSize = self.appearance.verifiedImageSize
        appearance.textColor = self.appearance.verifiedTextColor
        appearance.font = self.appearance.verifiedTextFont
        let view = CourseWidgetStatsItemView(appearance: appearance)
        view.image = UIImage(named: "course-info-verified")!
        view.text = NSLocalizedString("CourseMeetsRecommendations", comment: "")
        return view
    }()

    // Stack view for stat items (learners, rating, ...) and "verified" mark
    private lazy var marksStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = self.appearance.marksStackViewSpacing
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()

    // Stack view for title and cover
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = self.appearance.titleStackViewSpacing
        stackView.axis = .horizontal
        return stackView
    }()

    private lazy var statsView = CourseInfoStatsView()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // All elements have fixed height except verified view
    func calculateHeight(hasVerifiedMark: Bool) -> CGFloat {
        let verifiedMarkHeight = self.verifiedSignView.appearance.imageViewSize.height
            + self.appearance.marksStackViewSpacing
        return self.appearance.titleStackViewInsets.bottom
            + self.appearance.coverImageViewSize.height
            + self.appearance.marksStackViewInsets.bottom
            + self.appearance.statsViewHeight
            + self.appearance.actionButtonInsets.bottom
            + self.appearance.actionButtonHeight
            + self.appearance.actionButtonInsets.top
            + (hasVerifiedMark ? verifiedMarkHeight : 0)
    }

    // MARK: View model

    func configure(viewModel: CourseInfoHeaderViewModel) {
        self.loadImage(url: viewModel.coverImageURL)

        self.titleLabel.text = viewModel.title

        self.statsView.learnersLabelText = viewModel.learnersLabelText
        self.statsView.rating = viewModel.rating
        self.statsView.progress = viewModel.progress

        self.verifiedSignView.isHidden = !viewModel.isVerified
    }

    // MARK: Loading state

    func showLoading() {
        self.skeleton.viewBuilder = {
            CourseInfoHeaderSkeletonView()
        }

        self.actionButton.isHidden = true
        self.marksStackView.isHidden = true
        self.titleLabel.isHidden = true
        self.loadImage(url: nil)

        self.skeleton.show()
    }

    func hideLoading() {
        self.actionButton.isHidden = false
        self.marksStackView.isHidden = false
        self.titleLabel.isHidden = false

        self.skeleton.hide()
    }

    // MARK: Private methods

    private func loadImage(url: URL?) {
        self.backgroundView.loadImage(url: url)
        self.coverImageView.loadImage(url: url)
    }
}

extension CourseInfoHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.titleStackView.addArrangedSubview(self.coverImageView)
        self.titleStackView.addArrangedSubview(self.titleLabel)

        self.marksStackView.addArrangedSubview(self.statsView)
        self.marksStackView.addArrangedSubview(self.verifiedSignView)

        self.addSubview(self.backgroundView)
        self.addSubview(self.actionButton)
        self.addSubview(self.titleStackView)
        self.addSubview(self.marksStackView)
    }

    func makeConstraints() {
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.titleStackView.translatesAutoresizingMaskIntoConstraints = false
        self.titleStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(self.appearance.titleStackViewInsets.left)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.titleStackViewInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.titleStackViewInsets.bottom)
        }

        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.coverImageViewSize)
        }

        self.titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.statsView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.statsViewHeight)
        }

        self.marksStackView.translatesAutoresizingMaskIntoConstraints = false
        self.marksStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom
                .equalTo(self.titleStackView.snp.top)
                .offset(-self.appearance.marksStackViewInsets.bottom)
        }

        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.snp.makeConstraints { make in
            make.bottom
                .equalTo(self.statsView.snp.top)
                .offset(-self.appearance.actionButtonInsets.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(self.appearance.actionButtonHeight)
            make.width
                .equalTo(self.snp.width)
                .multipliedBy(self.appearance.actionButtonWidthRatio)
        }
    }
}
