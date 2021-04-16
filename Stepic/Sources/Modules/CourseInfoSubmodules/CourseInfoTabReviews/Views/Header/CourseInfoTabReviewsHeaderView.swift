import SnapKit
import UIKit

extension CourseInfoTabReviewsHeaderView {
    struct Appearance {
        let buttonSpacing: CGFloat = 16.0

        let buttonTintColor = UIColor.stepikMaterialPrimaryText
        let buttonFont = Typography.subheadlineFont
        let buttonImageInsets = UIEdgeInsets(top: 1.5, left: 0, bottom: 0, right: 0)
        let buttonTitleInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        let buttonImageSize = CGSize(width: 15, height: 15)

        let labelFont = Typography.subheadlineFont
        let labelTextColor = UIColor.stepikMaterialSecondaryText

        let insets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)

        let separatorHeight: CGFloat = 0.5
    }
}

final class CourseInfoTabReviewsHeaderView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.buttonSpacing
        return stackView
    }()

    private lazy var reviewButton: ImageButton = {
        let button = ImageButton()
        button.image = UIImage(named: "course-info-reviews-write")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = self.appearance.buttonTintColor
        button.title = NSLocalizedString("WriteCourseReviewActionCreate", comment: "")
        button.font = self.appearance.buttonFont
        button.imageInsets = self.appearance.buttonImageInsets
        button.titleInsets = self.appearance.buttonTitleInsets
        button.imageSize = self.appearance.buttonImageSize
        button.addTarget(self, action: #selector(self.onReviewButtonClicked), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var reviewDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("WriteCourseReviewActionNotAllowedDescription", comment: "")
        label.font = self.appearance.labelFont
        label.textColor = self.appearance.labelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var separatorView = SeparatorView()

    private var currentReviewAction = ReviewAction.write

    var shouldShowWriteReviewButton = false {
        didSet {
            self.currentReviewAction = .write
            self.updateReviewButton()
        }
    }

    var shouldShowEditReviewButton = false {
        didSet {
            self.currentReviewAction = .edit
            self.updateReviewButton()
        }
    }

    var shouldShowWriteReviewBanner = true {
        didSet {
            self.reviewDescriptionLabel.isHidden = !self.shouldShowWriteReviewBanner
        }
    }

    var writeReviewBannerText: String? {
        didSet {
            self.reviewDescriptionLabel.text = self.writeReviewBannerText
        }
    }

    var onWriteReviewButtonClick: (() -> Void)?
    var onEditReviewButtonClick: (() -> Void)?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    // MARK: - Private API

    private func updateReviewButton() {
        let isVisible = self.shouldShowWriteReviewButton || self.shouldShowEditReviewButton
        if isVisible {
            self.shouldShowWriteReviewBanner = false
        }

        self.reviewButton.isHidden = !isVisible
        self.reviewButton.title = self.currentReviewAction.title
    }

    @objc
    private func onReviewButtonClicked() {
        switch self.currentReviewAction {
        case .write:
            self.onWriteReviewButtonClick?()
        case .edit:
            self.onEditReviewButtonClick?()
        }
    }

    // MARK: - Types

    private enum ReviewAction {
        case write
        case edit

        var title: String {
            switch self {
            case .write:
                return NSLocalizedString("WriteCourseReviewActionCreate", comment: "")
            case .edit:
                return NSLocalizedString("WriteCourseReviewActionEdit", comment: "")
            }
        }
    }
}

// MARK: - CourseInfoTabReviewsHeaderView: ProgrammaticallyInitializableViewProtocol -

extension CourseInfoTabReviewsHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)
        self.addSubview(self.reviewDescriptionLabel)
        self.addSubview(self.separatorView)

        self.stackView.addArrangedSubview(self.reviewButton)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.insets.right).priority(999)
        }

        self.reviewDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.reviewDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalTo(self.separatorView.snp.top)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.top
                .equalTo(self.stackView.snp.bottom)
                .offset(self.appearance.insets.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }
}
