import SnapKit
import UIKit

extension CertificatesListCellView {
    struct Appearance {
        let minCellHeight: CGFloat = 142

        let certificateTypeViewInsets = LayoutInsets.default

        let courseCoverViewCornerRadius: CGFloat = 8
        let courseCoverViewInsets = LayoutInsets.default
        let courseCoverViewSize = CGSize(width: 60, height: 60)

        let titleLabelTextColor = UIColor.stepikMaterialPrimaryText
        let titleLabelFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let titleLabelInsets = LayoutInsets(top: 8, left: 16, bottom: 8, right: 8)

        let dateLabelTextColor = UIColor.stepikMaterialSecondaryText
        let dateLabelFont = Typography.caption1Font
        let dateLabelInsets = LayoutInsets(top: 8, left: 16, bottom: 16, right: 8)

        let gradeLabelTextColor = UIColor.stepikMaterialSecondaryText
        let gradeLabelFont = Typography.caption1Font
        let gradeLabelInsets = LayoutInsets(top: 8, left: 8, bottom: 16, right: 16)

        let cornerRadius: CGFloat = 16

        let borderColor = UIColor.black.withAlphaComponent(0.1)
        let borderWidth: CGFloat = 0.5

        let shadowColor = UIColor.black
        let shadowOffset = CGSize(width: 0, height: 0)
        let shadowRadius: CGFloat = 4
        let shadowOpacity: Float = 0.1

        let backgroundColor = UIColor.dynamic(light: .stepikBackground, dark: .stepikSecondaryBackground)
    }
}

final class CertificatesListCellView: UIControl {
    let appearance: Appearance

    private lazy var certificateTypeView = CertificatesListCertificateTypeView()

    private lazy var courseCoverView: CourseWidgetCoverView = {
        let appearance = CourseWidgetCoverView.Appearance(cornerRadius: self.appearance.courseCoverViewCornerRadius)
        let view = CourseWidgetCoverView(appearance: appearance)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 3
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.dateLabelFont
        label.textColor = self.appearance.dateLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var gradeLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.gradeLabelFont
        label.textColor = self.appearance.gradeLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()

    override var isHighlighted: Bool {
        didSet {
            self.animateBounce()
        }
    }

    override var intrinsicContentSize: CGSize {
        let titleHeightWithInsets = self.appearance.titleLabelInsets.top + self.titleLabel.intrinsicContentSize.height

        let height = self.appearance.certificateTypeViewInsets.top
            + self.certificateTypeView.intrinsicContentSize.height
            + max(titleHeightWithInsets, self.appearance.courseCoverViewSize.height)
            + self.appearance.dateLabelInsets.top
            + self.dateLabel.intrinsicContentSize.height
            + self.appearance.dateLabelInsets.bottom

        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(self.appearance.minCellHeight, height)
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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.borderColor = self.appearance.borderColor.cgColor
        self.layer.borderWidth = self.appearance.borderWidth

        self.layer.shadowColor = self.appearance.shadowColor.cgColor
        self.layer.shadowOffset = self.appearance.shadowOffset
        self.layer.shadowRadius = self.appearance.shadowRadius
        self.layer.shadowOpacity = self.appearance.shadowOpacity
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.layer.cornerRadius
        ).cgPath

        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }

    func configure(viewModel: CertificatesListItemViewModel?) {
        self.certificateTypeView.type = viewModel?.certificateType ?? .regular

        self.courseCoverView.coverImageURL = viewModel?.courseCoverURL

        self.titleLabel.text = viewModel?.courseTitle
        self.dateLabel.text = viewModel?.formattedIssueDate
        self.gradeLabel.text = viewModel?.formattedGrade
    }
}

extension CertificatesListCellView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.certificateTypeView)
        self.addSubview(self.courseCoverView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.dateLabel)
        self.addSubview(self.gradeLabel)
    }

    func makeConstraints() {
        self.certificateTypeView.translatesAutoresizingMaskIntoConstraints = false
        self.certificateTypeView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(self.appearance.certificateTypeViewInsets.edgeInsets)
        }

        self.courseCoverView.translatesAutoresizingMaskIntoConstraints = false
        self.courseCoverView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(self.appearance.courseCoverViewInsets.edgeInsets)
            make.size.equalTo(self.appearance.courseCoverViewSize)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.certificateTypeView.snp.bottom).offset(self.appearance.titleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.trailing.equalTo(self.courseCoverView.snp.leading).offset(-self.appearance.titleLabelInsets.right)
        }

        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(self.titleLabel.snp.bottom).offset(self.appearance.dateLabelInsets.top)
            make.leading.bottom.equalToSuperview().inset(self.appearance.dateLabelInsets.edgeInsets)
        }

        self.gradeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.gradeLabel.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(self.appearance.gradeLabelInsets.edgeInsets)
        }
    }
}
