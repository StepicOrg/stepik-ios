import SnapKit
import UIKit

extension CertificatesListCellView {
    struct Appearance {
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

        let backgroundColor = UIColor.dynamic(light: .stepikBackground, dark: .stepikSecondaryBackground)
    }
}

final class CertificatesListCellView: UIView {
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
