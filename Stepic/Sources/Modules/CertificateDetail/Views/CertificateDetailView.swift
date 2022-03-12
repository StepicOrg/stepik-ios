import SnapKit
import UIKit

extension CertificateDetailView {
    struct Appearance {
        let issueDateLabelFont = Typography.caption1Font
        let issueDateLabelTextColor = UIColor.stepikMaterialSecondaryText

        let userRankLabelFont = Typography.caption1Font
        let userRankLabelTextColor = UIColor.stepikVioletFixed

        let editButtonHeight = 44

        let scrollableStackViewSpacing: CGFloat = 16
        let scrollableStackViewContentInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        let scrollableStackViewLayoutInsets = LayoutInsets.default

        let backgroundColor = UIColor.stepikBackground
    }
}

final class CertificateDetailView: UIView {
    let appearance: Appearance

    private lazy var issueDateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.issueDateLabelFont
        label.textColor = self.appearance.issueDateLabelTextColor
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var gradeView = CertificateDetailGradeView()

    private lazy var courseDetailTitleView = CertificateDetailVerticalTitleView()

    private lazy var recipientDetailTitleView = CertificateDetailVerticalTitleView()

    private lazy var userRankLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.userRankLabelFont
        label.textColor = self.appearance.userRankLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var previewView = CertificateDetailPreviewView()

    private lazy var editButton: CertificateDetailEditButton = {
        let button = CertificateDetailEditButton()
        button.addTarget(self, action: #selector(self.editButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var scrollableStackView: ScrollableStackView = {
        let scrollableStackView = ScrollableStackView(orientation: .vertical)
        scrollableStackView.contentInsets = self.appearance.scrollableStackViewContentInsets
        scrollableStackView.spacing = self.appearance.scrollableStackViewSpacing
        scrollableStackView.showsVerticalScrollIndicator = false
        scrollableStackView.showsHorizontalScrollIndicator = false
        return scrollableStackView
    }()

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

    // MARK: Public API

    func showLoading() {
        self.scrollableStackView.isHidden = true

        self.skeleton.viewBuilder = { CertificateDetailSkeletonView() }
        self.skeleton.show()
    }

    func hideLoading() {
        self.scrollableStackView.isHidden = false
        self.skeleton.hide()
    }

    func configure(viewModel: CertificateDetailViewModel) {
        self.issueDateLabel.text = viewModel.formattedIssueDate

        self.gradeView.badgeStyle = viewModel.isWithDistinction ? .distinction : .regular
        self.gradeView.text = viewModel.formattedGrade

        self.courseDetailTitleView.headlineText = NSLocalizedString("CertificateDetailHeadlineCourseTitle", comment: "")
        self.courseDetailTitleView.bodyText = viewModel.courseTitle

        self.recipientDetailTitleView.headlineText = NSLocalizedString(
            "CertificateDetailHeadlineRecipientTitle",
            comment: ""
        )
        self.recipientDetailTitleView.bodyText = viewModel.userFullName

        self.userRankLabel.text = viewModel.formattedUserRank
        self.userRankLabel.isHidden = self.userRankLabel.text?.isEmpty ?? true

        self.previewView.loadImage(url: viewModel.previewURL)

        self.editButton.isHidden = !viewModel.isEditAvailable
    }

    // MARK: Private API

    @objc
    private func editButtonClicked() {
        print(#function)
    }
}

extension CertificateDetailView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)

        let issueDateAndGradeStackView = UIStackView()
        issueDateAndGradeStackView.axis = .horizontal
        issueDateAndGradeStackView.distribution = .equalSpacing
        issueDateAndGradeStackView.alignment = .center
        issueDateAndGradeStackView.addArrangedSubview(self.issueDateLabel)
        issueDateAndGradeStackView.addArrangedSubview(self.gradeView)
        self.scrollableStackView.addArrangedView(issueDateAndGradeStackView)

        self.scrollableStackView.addArrangedView(self.courseDetailTitleView)
        self.scrollableStackView.addArrangedView(self.recipientDetailTitleView)
        self.scrollableStackView.addArrangedView(self.userRankLabel)
        self.scrollableStackView.addArrangedView(self.previewView)
        self.scrollableStackView.addArrangedView(self.editButton)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading
                .trailing
                .equalTo(self.safeAreaLayoutGuide)
                .inset(self.appearance.scrollableStackViewLayoutInsets.edgeInsets)
        }

        self.editButton.translatesAutoresizingMaskIntoConstraints = false
        self.editButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.editButtonHeight)
        }
    }
}
