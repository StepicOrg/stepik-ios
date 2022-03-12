import SnapKit
import UIKit

extension CertificateDetailView {
    struct Appearance {
        let issueDateLabelFont = Typography.caption1Font
        let issueDateLabelTextColor = UIColor.stepikMaterialSecondaryText

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

    private lazy var scrollableStackView: ScrollableStackView = {
        let scrollableStackView = ScrollableStackView(orientation: .vertical)
        scrollableStackView.contentInsets = self.appearance.scrollableStackViewContentInsets
        scrollableStackView.spacing = self.appearance.scrollableStackViewSpacing
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
    }
}
