//
// CourseInfoTabInfoView.swift
// stepik-ios
//
//  Created by Ivan Magda on 11/1/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

protocol CourseInfoTabInfoViewDelegate: class {
    func courseInfoTabInfoViewDidTapOnJoin(_ courseInfoTabInfoView: CourseInfoTabInfoView)
}

extension CourseInfoTabInfoView {
    struct Appearance {
        let stackViewSpacing: CGFloat = 0

        let blockInsets = UIEdgeInsets(top: 40, left: 20, bottom: 0, right: 47)
        let innerInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 47)

        let joinButtonInsets = UIEdgeInsets(top: 40, left: 47, bottom: 40, right: 47)
        let joinButtonHeight: CGFloat = 47
        let joinButtonBackgroundColor = UIColor.stepicGreen
        let joinButtonFont = UIFont.systemFont(ofSize: 14)
        let joinButtonTextColor = UIColor.white
        let joinButtonCornerRadius: CGFloat = 7
    }
}

final class CourseInfoTabInfoView: UIView {
    weak var delegate: CourseInfoTabInfoViewDelegate?

    private let appearance: Appearance

    private lazy var scrollableStackView: ScrollableStackView = {
        let stackView = ScrollableStackView(frame: .zero, orientation: .vertical)
        stackView.showsVerticalScrollIndicator = false
        stackView.showsHorizontalScrollIndicator = false
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = self.appearance.joinButtonBackgroundColor
        button.titleLabel?.font = self.appearance.joinButtonFont
        button.tintColor = self.appearance.joinButtonTextColor
        button.layer.cornerRadius = self.appearance.joinButtonCornerRadius

        button.setTitle(NSLocalizedString("JoinCourse", comment: ""), for: .normal)
        button.addTarget(
            self,
            action: #selector(self.joinButtonClicked(sender:)),
            for: .touchUpInside
        )

        return button
    }()

    // MARK: Init

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        delegate: CourseInfoTabInfoViewDelegate? = nil
    ) {
        self.appearance = appearance
        self.delegate = delegate
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public API

    func showLoading() {
        self.skeleton.viewBuilder = {
            CourseInfoTabInfoSkeletonView()
        }
        self.skeleton.show()
    }

    func hideLoading() {
        self.skeleton.hide()
    }

    func configure(viewModel: CourseInfoTabInfoViewModel) {
        if !self.scrollableStackView.arrangedSubviews.isEmpty {
            self.scrollableStackView.removeAllArrangedViews()
        }

        let authorView = CourseInfoTabInfoTextBlockView(
            appearance: .init(headerViewInsets: self.appearance.innerInsets)
        )
        authorView.configure(
            viewModel: .init(
                icon: self.getBlockIcon(.author),
                title: "\(self.getBlockTitle(.author)) \(viewModel.author)",
                message: ""
            )
        )
        self.scrollableStackView.addArrangedView(authorView)

        self.addIntroVideoView(introVideoURL: viewModel.introVideoURL)

        self.addTextBlockView(block: .about, message: viewModel.aboutText)
        self.addTextBlockView(block: .requirements, message: viewModel.requirementsText)
        self.addTextBlockView(block: .targetAudience, message: viewModel.targetAudienceText)

        self.addInstructorsView(instructors: viewModel.instructors)

        self.addTextBlockView(block: .timeToComplete, message: viewModel.timeToCompleteText)
        self.addTextBlockView(block: .language, message: viewModel.languageText)
        self.addTextBlockView(block: .certificate, message: viewModel.certificateText)
        self.addTextBlockView(block: .certificateDetails, message: viewModel.certificateDetailsText)

        self.addJoinButton()
    }

    // MARK: Actions

    @objc
    private func joinButtonClicked(sender: UIButton) {
        self.delegate?.courseInfoTabInfoViewDidTapOnJoin(self)
    }

    // MARK: Private API

    private func addTextBlockView(
        block: CourseInfoTabInfoBlock,
        message: String,
        headerViewInsets: UIEdgeInsets = Appearance().blockInsets
    ) {
        let textBlockView = CourseInfoTabInfoTextBlockView(
            appearance: .init(headerViewInsets: headerViewInsets)
        )
        textBlockView.configure(
            viewModel: .init(
                icon: self.getBlockIcon(block),
                title: self.getBlockTitle(block),
                message: message
            )
        )
        self.scrollableStackView.addArrangedView(textBlockView)
    }

    private func addIntroVideoView(introVideoURL: URL?) {
        let introVideoView = CourseInfoTabInfoIntroVideoBlockView()
        introVideoView.configure(
            viewModel: .init(introURL: introVideoURL)
        )
        self.scrollableStackView.addArrangedView(introVideoView)
    }

    private func addInstructorsView(instructors: [CourseInfoTabInfoInstructorViewModel]) {
        let instructorsView = CourseInfoTabInfoInstructorsBlockView()
        instructorsView.configure(
            viewModel: .init(
                icon: self.getBlockIcon(.instructors),
                title: self.getBlockTitle(.instructors),
                instructors: instructors
            )
        )
        self.scrollableStackView.addArrangedView(instructorsView)
    }

    private func addJoinButton() {
        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        self.joinButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(self.joinButton)

        self.scrollableStackView.addArrangedView(buttonContainer)
        self.joinButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.joinButtonHeight)
            make.leading.top.trailing.bottom
                .equalToSuperview()
                .inset(self.appearance.joinButtonInsets)
        }
    }

    private func getBlockIcon(_ block: CourseInfoTabInfoBlock) -> UIImage? {
        return self.getResources(block: block).icon
    }

    private func getBlockTitle(_ block: CourseInfoTabInfoBlock) -> String {
        return self.getResources(block: block).title
    }

    private func getResources(block: CourseInfoTabInfoBlock) -> (title: String, icon: UIImage?) {
        switch block {
        case .author:
            return (
                NSLocalizedString("CourseInfoTitleAuthor", comment: ""),
                UIImage(named: "course-info-instructor")
            )
        case .introVideo:
            return ("", nil)
        case .about:
            return (
                NSLocalizedString("CourseInfoTitleAbout", comment: ""),
                UIImage(named: "course-info-about")
            )
        case .requirements:
            return (
                NSLocalizedString("CourseInfoTitleRequirements", comment: ""),
                UIImage(named: "course-info-requirements")
            )
        case .targetAudience:
            return (
                NSLocalizedString("CourseInfoTitleTargetAudience", comment: ""),
                UIImage(named: "course-info-target-audience")
            )
        case .instructors:
            return (
                NSLocalizedString("CourseInfoTitleInstructors", comment: ""),
                UIImage(named: "course-info-instructor")
            )
        case .timeToComplete:
            return (
                NSLocalizedString("CourseInfoTitleTimeToComplete", comment: ""),
                UIImage(named: "course-info-time-to-complete")
            )
        case .language:
            return (
                NSLocalizedString("CourseInfoTitleLanguage", comment: ""),
                UIImage(named: "course-info-language")
            )
        case .certificate:
            return (
                NSLocalizedString("CourseInfoTitleCertificate", comment: ""),
                UIImage(named: "course-info-certificate")
            )
        case .certificateDetails:
            return (
                NSLocalizedString("CourseInfoTitleCertificateDetails", comment: ""),
                UIImage(named: "course-info-certificate-details")
            )
        }
    }
}

// MARK: - CourseInfoTabInfoView: ProgrammaticallyInitializableViewProtocol -

extension CourseInfoTabInfoView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
