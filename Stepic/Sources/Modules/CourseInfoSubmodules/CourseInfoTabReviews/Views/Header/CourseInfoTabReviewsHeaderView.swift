import SnapKit
import UIKit

extension CourseInfoTabReviewsHeaderView {
    struct Appearance {
        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = LayoutInsets(top: 16)

        let summaryViewInsets = LayoutInsets(horizontal: 16)

        let reviewButtonHeight: CGFloat = 44
        let reviewButtonInsets = LayoutInsets(horizontal: 16)

        let reviewDescriptionLabelFont = Typography.subheadlineFont
        let reviewDescriptionLabelTextColor = UIColor.stepikMaterialSecondaryText
        let reviewDescriptionLabelInsets = LayoutInsets(horizontal: 16)

        let separatorHeight: CGFloat = 0.5
    }
}

final class CourseInfoTabReviewsHeaderView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    private lazy var summaryView = CourseInfoTabReviewsSummaryView()

    private lazy var summaryContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private lazy var summarySeparatorView: SeparatorView = {
        let view = SeparatorView()
        view.isHidden = true
        return view
    }()

    private lazy var reviewButton: CourseInfoTabReviewsReviewButton = {
        let button = CourseInfoTabReviewsReviewButton()
        button.title = NSLocalizedString("WriteCourseReviewActionCreate", comment: "")
        button.addTarget(self, action: #selector(self.onReviewButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var reviewButtonContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private lazy var reviewDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("WriteCourseReviewActionNotAllowedDescription", comment: "")
        label.font = self.appearance.reviewDescriptionLabelFont
        label.textColor = self.appearance.reviewDescriptionLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var reviewDescriptionContainerView = UIView()

    private lazy var reviewSeparatorView = SeparatorView()

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
            self.reviewDescriptionContainerView.isHidden = !self.shouldShowWriteReviewBanner
            self.invalidateIntrinsicContentSize()
        }
    }

    var writeReviewBannerText: String? {
        didSet {
            self.reviewDescriptionLabel.text = self.writeReviewBannerText
            self.invalidateIntrinsicContentSize()
        }
    }

    var summaryViewModel: CourseInfoTabReviewsSummaryViewModel? {
        didSet {
            self.summaryView.configure(viewModel: self.summaryViewModel ?? .empty)
            self.summaryContainerView.isHidden = self.summaryViewModel == nil
            self.summarySeparatorView.isHidden = self.summaryViewModel == nil

            self.invalidateIntrinsicContentSize()
        }
    }

    var onWriteReviewButtonClick: (() -> Void)?
    var onEditReviewButtonClick: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        let stackViewIntrinsicContentSize = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.stackViewInsets.top + stackViewIntrinsicContentSize.height
        )
    }

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

        self.reviewButtonContainerView.isHidden = !isVisible
        self.reviewButton.title = self.currentReviewAction.title

        self.invalidateIntrinsicContentSize()
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

        self.summaryContainerView.addSubview(self.summaryView)
        self.reviewButtonContainerView.addSubview(self.reviewButton)
        self.reviewDescriptionContainerView.addSubview(self.reviewDescriptionLabel)

        self.stackView.addArrangedSubview(self.summaryContainerView)
        self.stackView.addArrangedSubview(self.summarySeparatorView)
        self.stackView.addArrangedSubview(self.reviewButtonContainerView)
        self.stackView.addArrangedSubview(self.reviewDescriptionContainerView)
        self.stackView.addArrangedSubview(self.reviewSeparatorView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.stackViewInsets.edgeInsets)
        }

        self.summaryView.translatesAutoresizingMaskIntoConstraints = false
        self.summaryView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.summaryViewInsets.edgeInsets)
        }

        self.summarySeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.summarySeparatorView.snp.makeConstraints { $0.height.equalTo(self.appearance.separatorHeight) }

        self.reviewButton.translatesAutoresizingMaskIntoConstraints = false
        self.reviewButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.reviewButtonInsets.edgeInsets)
            make.height.equalTo(self.appearance.reviewButtonHeight)
        }

        self.reviewDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.reviewDescriptionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.reviewDescriptionLabelInsets.edgeInsets)
        }

        self.reviewSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.reviewSeparatorView.snp.makeConstraints { $0.height.equalTo(self.appearance.separatorHeight) }
    }
}
