import SnapKit
import UIKit

extension NewProfileCertificatesCertificateWidgetView {
    struct Appearance {
        let courseCoverViewCornerRadius: CGFloat = 4
        let courseCoverViewInsets = LayoutInsets(top: 16, left: 16)
        let courseCoverViewSize = CGSize(width: 24, height: 24)

        let courseCoverTitleFont = UIFont.systemFont(ofSize: 11, weight: .semibold)
        let courseCoverTitleTextColor = UIColor.stepikSystemSecondaryText
        let courseCoverTitleInsets = LayoutInsets(left: 4, right: 16)

        let courseTitleFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        let courseTitleTextColor = UIColor.stepikSystemPrimaryText

        let bodyStackViewSpacing: CGFloat = 2
        let bodyStackViewInsets = LayoutInsets(top: 8, bottom: 16)

        let progressViewHeight: CGFloat = 20
    }
}

final class NewProfileCertificatesCertificateWidgetView: UIView {
    let appearance: Appearance

    private lazy var courseCoverView: CourseWidgetCoverView = {
        let appearance = CourseWidgetCoverView.Appearance(cornerRadius: self.appearance.courseCoverViewCornerRadius)
        let view = CourseWidgetCoverView(appearance: appearance)
        return view
    }()

    private lazy var courseCoverTitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.courseCoverTitleFont
        label.textColor = self.appearance.courseCoverTitleTextColor
        label.numberOfLines = 2
        return label
    }()

    private lazy var courseTitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.courseTitleFont
        label.textColor = self.appearance.courseTitleTextColor
        label.numberOfLines = 3
        return label
    }()

    private lazy var progressView = NewProfileCertificatesCertificateWidgetProgressView()

    private lazy var bodyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.bodyStackViewSpacing
        return stackView
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: NewProfileCertificatesCertificateViewModel) {
        self.courseCoverView.coverImageURL = viewModel.courseImageURL

        let courseCoverText = viewModel.certificateType == .distinction
            ? NSLocalizedString("CertificateWithDistinction", comment: "")
            : NSLocalizedString("Certificate", comment: "")
        self.courseCoverTitleLabel.text = courseCoverText.uppercased()

        self.courseTitleLabel.text = viewModel.courseTitle

        if let certificateGrade = viewModel.certificateGrade {
            self.progressView.progress = certificateGrade
            self.progressView.certificateType = viewModel.certificateType
            self.progressView.isHidden = false
        } else {
            self.progressView.isHidden = true
        }
    }
}

extension NewProfileCertificatesCertificateWidgetView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.courseCoverView)
        self.addSubview(self.courseCoverTitleLabel)
        self.addSubview(self.bodyStackView)
        self.bodyStackView.addArrangedSubview(self.courseTitleLabel)
        self.bodyStackView.addArrangedSubview(self.progressView)
    }

    func makeConstraints() {
        self.courseCoverView.translatesAutoresizingMaskIntoConstraints = false
        self.courseCoverView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.courseCoverViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.courseCoverViewInsets.left)
            make.width.equalTo(self.appearance.courseCoverViewSize.width)
            make.height.equalTo(self.appearance.courseCoverViewSize.height)
        }

        self.courseCoverTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.courseCoverTitleLabel.snp.makeConstraints { make in
            make.leading
                .equalTo(self.courseCoverView.snp.trailing)
                .offset(self.appearance.courseCoverTitleInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.courseCoverTitleInsets.right)
            make.centerY.equalTo(self.courseCoverView.snp.centerY)
        }

        self.bodyStackView.translatesAutoresizingMaskIntoConstraints = false
        self.bodyStackView.snp.makeConstraints { make in
            make.top.equalTo(self.courseCoverView.snp.bottom).offset(self.appearance.bodyStackViewInsets.top)
            make.leading.equalTo(self.courseCoverView.snp.leading)
            make.trailing.equalTo(self.courseCoverTitleLabel.snp.trailing)
            make.bottom.equalToSuperview().offset(-self.appearance.bodyStackViewInsets.bottom)
        }

        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.progressViewHeight)
        }
    }
}
