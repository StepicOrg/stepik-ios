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
        self.hideLoading()

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

        self.addAuthorView(author: viewModel.author)
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

    private func addAuthorView(author: String) {
        let authorView = CourseInfoTabInfoTextBlockView(
            appearance: .init(headerViewInsets: self.appearance.innerInsets)
        )
        authorView.headerView.icon = Block.author.icon
        authorView.headerView.title = "\(Block.author.title) \(author)"

        self.scrollableStackView.addArrangedView(authorView)
    }

    private func addTextBlockView(
        block: Block,
        message: String,
        headerViewInsets: UIEdgeInsets = Appearance().blockInsets
    ) {
        let textBlockView = CourseInfoTabInfoTextBlockView(
            appearance: .init(headerViewInsets: headerViewInsets)
        )
        textBlockView.headerView.icon = block.icon
        textBlockView.headerView.title = block.title
        textBlockView.message = message

        self.scrollableStackView.addArrangedView(textBlockView)
    }

    private func addIntroVideoView(introVideoURL: URL?) {
        self.scrollableStackView.addArrangedView(CourseInfoTabInfoIntroVideoBlockView())
    }

    private func addInstructorsView(instructors: [CourseInfoTabInfoInstructorViewModel]) {
        let instructorsView = CourseInfoTabInfoInstructorsBlockView()
        instructorsView.configure(instructors: instructors)
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

// MARK: - CourseInfoTabInfoView (Block) -

extension CourseInfoTabInfoView {
    enum Block {
        case author
        case introVideo
        case about
        case requirements
        case targetAudience
        case instructors
        case timeToComplete
        case language
        case certificate
        case certificateDetails

        var icon: UIImage? {
            switch self {
            case .author:
                return UIImage(named: "course-info-instructor")
            case .introVideo:
                return nil
            case .about:
                return UIImage(named: "course-info-about")
            case .requirements:
                return UIImage(named: "course-info-requirements")
            case .targetAudience:
                return UIImage(named: "course-info-target-audience")
            case .instructors:
                return UIImage(named: "course-info-instructor")
            case .timeToComplete:
                return UIImage(named: "course-info-time-to-complete")
            case .language:
                return UIImage(named: "course-info-language")
            case .certificate:
                return UIImage(named: "course-info-certificate")
            case .certificateDetails:
                return UIImage(named: "course-info-certificate-details")
            }
        }

        var title: String {
            switch self {
            case .author:
                return NSLocalizedString("CourseInfoTitleAuthor", comment: "")
            case .introVideo:
                return ""
            case .about:
                return NSLocalizedString("CourseInfoTitleAbout", comment: "")
            case .requirements:
                return NSLocalizedString("CourseInfoTitleRequirements", comment: "")
            case .targetAudience:
                return NSLocalizedString("CourseInfoTitleTargetAudience", comment: "")
            case .instructors:
                return NSLocalizedString("CourseInfoTitleInstructors", comment: "")
            case .timeToComplete:
                return NSLocalizedString("CourseInfoTitleTimeToComplete", comment: "")
            case .language:
                return NSLocalizedString("CourseInfoTitleLanguage", comment: "")
            case .certificate:
                return NSLocalizedString("CourseInfoTitleCertificate", comment: "")
            case .certificateDetails:
                return NSLocalizedString("CourseInfoTitleCertificateDetails", comment: "")
            }
        }
    }
}
