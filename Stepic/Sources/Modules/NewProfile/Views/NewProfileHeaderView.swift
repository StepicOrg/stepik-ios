import SnapKit
import UIKit

extension NewProfileHeaderView {
    struct Appearance {
        let coverImageViewHeight: CGFloat = 176

        let avatarImageViewSize = CGSize(width: 64, height: 64)
        let avatarImageViewInsets = LayoutInsets(top: 16, left: 16)
        let avatarImageViewBorderWidth: CGFloat = 0.5
        let avatarImageViewBorderColor = UIColor.stepikSeparator

        let usernameLabelTextColor = UIColor.stepikSystemPrimaryText
        let usernameLabelFont = UIFont.systemFont(ofSize: 20, weight: .bold)

        let shortBioLabelTextColor = UIColor.stepikSystemSecondaryText
        let shortBioLabelFont = UIFont.systemFont(ofSize: 12, weight: .medium)

        let infoStackViewSpacing: CGFloat = 8
        let infoStackViewInsets = LayoutInsets(left: 16, bottom: 16, right: 16)

        let backgroundColor = UIColor.stepikSecondaryGroupedBackground
    }
}

final class NewProfileHeaderView: UIView {
    let appearance: Appearance

    private lazy var coverView = NewProfileCoverView()

    private lazy var avatarImageView: AvatarImageView = {
        let avatarImageView = AvatarImageView()
        avatarImageView.shape = .circle(
            borderWidth: self.appearance.avatarImageViewBorderWidth,
            borderColor: self.appearance.avatarImageViewBorderColor
        )
        return avatarImageView
    }()

    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.usernameLabelTextColor
        label.font = self.appearance.usernameLabelFont
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()

    private lazy var shortBioLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.shortBioLabelTextColor
        label.font = self.appearance.shortBioLabelFont
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()

    private lazy var reputationRatingView = NewProfileRatingView(kind: .reputation)
    private lazy var knowledgeRatingView = NewProfileRatingView(kind: .knowledge)
    private lazy var certificatesRatingView = NewProfileRatingView(kind: .certificates)
    private lazy var coursesRatingView = NewProfileRatingView(kind: .courses)

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = self.appearance.infoStackViewSpacing
        return stackView
    }()

    private var coverViewTopConstraint: Constraint?
    private var coverViewHeightConstraint: Constraint?

    private var coverViewHeight: CGFloat = 0 {
        didSet {
            self.coverViewHeightConstraint?.update(offset: self.coverViewHeight)
        }
    }

    var additionalCoverViewHeight: CGFloat = 0 {
        didSet {
            if oldValue != self.additionalCoverViewHeight {
                self.coverViewHeight = max(
                    self.appearance.coverImageViewHeight,
                    self.appearance.coverImageViewHeight + self.additionalCoverViewHeight
                )
                self.coverViewTopConstraint?.update(offset: min(0, -self.additionalCoverViewHeight))
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        let infoStackViewIntrinsicContentSize = self.infoStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let contentHeight = max(infoStackViewIntrinsicContentSize.height, self.appearance.avatarImageViewSize.height)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.coverViewHeight
                + self.appearance.avatarImageViewInsets.top
                + contentHeight
                + self.appearance.infoStackViewInsets.bottom
        )
    }

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

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: NewProfileHeaderViewModel) {
        if viewModel.isOrganization, let coverURL = viewModel.coverURL {
            self.coverView.isHidden = false
            self.coverViewHeight = self.appearance.coverImageViewHeight
            self.coverView.imageURL = coverURL
        } else {
            self.coverView.isHidden = true
            self.coverViewHeight = 0
            self.coverView.imageURL = nil
        }

        if let avatarURL = viewModel.avatarURL {
            self.avatarImageView.set(with: avatarURL)
        } else {
            self.avatarImageView.reset()
        }

        self.usernameLabel.text = viewModel.username
        self.shortBioLabel.text = viewModel.shortBio
        self.shortBioLabel.isHidden = viewModel.shortBio.isEmpty
        self.configureProfileRatings(viewModel: viewModel)

        self.invalidateIntrinsicContentSize()
    }

    private func configureProfileRatings(viewModel: NewProfileHeaderViewModel) {
        if viewModel.isOrganization {
            let certificatesCount = viewModel.issuedCertificatesCount > 0 ? viewModel.issuedCertificatesCount : nil
            self.certificatesRatingView.number = certificatesCount
            self.certificatesRatingView.isHidden = certificatesCount == nil

            let createdCoursesCount = viewModel.createdCoursesCount > 0 ? viewModel.createdCoursesCount : nil
            self.coursesRatingView.number = createdCoursesCount
            self.coursesRatingView.isHidden = createdCoursesCount == nil

            self.reputationRatingView.isHidden = true
            self.knowledgeRatingView.isHidden = true
        } else {
            let reputationCount = viewModel.reputationCount > 0 ? viewModel.reputationCount : nil
            self.reputationRatingView.number = reputationCount
            self.reputationRatingView.isHidden = reputationCount == nil

            let knowledgeCount = viewModel.knowledgeCount > 0 ? viewModel.knowledgeCount : nil
            self.knowledgeRatingView.number = knowledgeCount
            self.knowledgeRatingView.isHidden = knowledgeCount == nil

            self.certificatesRatingView.isHidden = true
            self.coursesRatingView.isHidden = true
        }
    }
}

extension NewProfileHeaderView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.avatarImageView.reset()
        self.coverView.isHidden = true
        [
            self.reputationRatingView, self.knowledgeRatingView, self.certificatesRatingView, self.coursesRatingView
        ].forEach { $0.isHidden = true }
    }

    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.avatarImageView)

        self.addSubview(self.infoStackView)
        self.infoStackView.addArrangedSubview(self.usernameLabel)
        self.infoStackView.addArrangedSubview(self.shortBioLabel)
        self.infoStackView.addArrangedSubview(self.reputationRatingView)
        self.infoStackView.addArrangedSubview(self.knowledgeRatingView)
        self.infoStackView.addArrangedSubview(self.certificatesRatingView)
        self.infoStackView.addArrangedSubview(self.coursesRatingView)
    }

    func makeConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.snp.makeConstraints { make in
            self.coverViewTopConstraint = make.top.equalToSuperview().constraint
            make.leading.trailing.equalToSuperview()
            self.coverViewHeightConstraint = make.height.equalTo(0).constraint
        }

        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.snp.makeConstraints { make in
            make.top
                .equalTo(self.coverView.snp.bottom)
                .offset(self.appearance.avatarImageViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.avatarImageViewInsets.left)
            make.width.equalTo(self.appearance.avatarImageViewSize.width)
            make.height.equalTo(self.appearance.avatarImageViewSize.height)
        }

        self.infoStackView.translatesAutoresizingMaskIntoConstraints = false
        self.infoStackView.snp.makeConstraints { make in
            make.top.equalTo(self.avatarImageView.snp.top)
            make.leading
                .equalTo(self.avatarImageView.snp.trailing)
                .offset(self.appearance.infoStackViewInsets.left)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.infoStackViewInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.infoStackViewInsets.right)
        }
    }
}
