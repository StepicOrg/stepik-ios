import SnapKit
import UIKit

extension ExploreStepikAcademyBlockHeaderView {
    struct Appearance {
        let backgroundColor = UIColor.dynamic(light: .white, dark: .stepikSecondaryBackground)
        let cornerRadius: CGFloat = 13

        let shadowColor = UIColor.black
        let shadowOffset = CGSize(width: 0, height: 1)
        let shadowRadius: CGFloat = 4
        let shadowOpacity: Float = 0.08

        let titleLabelTextColor = UIColor.white
        let titleLabelFont = Typography.title3Font
        let titleLabelInsets = LayoutInsets(inset: 16)

        let headerImageViewWidth: CGFloat = 102
        let headerImageViewInsets = LayoutInsets(right: 10)

        let headerBackgroundColor = UIColor.dynamic(
            light: .black,
            dark: UIColor.stepikVioletFixed.withAlphaComponent(0.38)
        )
        let headerMinHeight: CGFloat = 80

        let descriptionLabelFont = Typography.subheadlineFont
        let descriptionLabelColor = UIColor.stepikMaterialSecondaryText
        let descriptionLabelInsets = LayoutInsets(inset: 16)

        let moreButtonTextColor = UIColor.dynamic(light: .stepikVioletFixed, dark: .stepikViolet05Fixed)
        let moreButtonFont = Typography.bodyFont
        let moreButtonInsets = LayoutInsets(top: 16, bottom: 16)
    }
}

final class ExploreStepikAcademyBlockHeaderView: UIView, ExploreBlockHeaderViewProtocol {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 3
        return label
    }()

    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "academy-header-illustration"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var headerContainerView = UIView()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.descriptionLabelFont
        label.textColor = self.appearance.descriptionLabelColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = self.appearance.moreButtonTextColor
        button.titleLabel?.font = self.appearance.moreButtonFont
        button.addTarget(self, action: #selector(self.moreButtonClicked), for: .touchUpInside)
        button.setTitle(NSLocalizedString("StepikAcademyCourseListHeaderMoreButtonTitle", comment: ""), for: .normal)
        return button
    }()

    var titleText: String? {
        didSet {
            self.titleLabel.text = self.titleText
        }
    }

    var summaryText: String? {
        didSet {
            self.descriptionLabel.text = self.summaryText
        }
    }

    var onShowAllButtonClick: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        let titleHeightWithInsets = self.appearance.titleLabelInsets.top
            + self.titleLabel.intrinsicContentSize.height
            + self.appearance.titleLabelInsets.bottom
        let headerHeight = max(self.appearance.headerMinHeight, titleHeightWithInsets)

        let height = headerHeight
            + self.appearance.descriptionLabelInsets.top
            + self.descriptionLabel.intrinsicContentSize.height
            + self.appearance.moreButtonInsets.top
            + self.moreButton.intrinsicContentSize.height
            + self.appearance.moreButtonInsets.bottom

        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundColor = self.appearance.backgroundColor
        self.layer.cornerRadius = self.appearance.cornerRadius

        self.layer.shadowColor = self.appearance.shadowColor.cgColor
        self.layer.shadowOffset = self.appearance.shadowOffset
        self.layer.shadowRadius = self.appearance.shadowRadius
        self.layer.shadowOpacity = self.appearance.shadowOpacity
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath

        let headerContainerViewMaskPath = UIBezierPath(
            roundedRect: self.headerContainerView.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: self.appearance.cornerRadius, height: self.appearance.cornerRadius)
        )
        let headerContainerViewShape = CAShapeLayer()
        headerContainerViewShape.path = headerContainerViewMaskPath.cgPath
        self.headerContainerView.layer.mask = headerContainerViewShape

        self.headerContainerView.layer.masksToBounds = true
        self.headerContainerView.clipsToBounds = true
        self.headerContainerView.backgroundColor = self.appearance.headerBackgroundColor
    }

    @objc
    private func moreButtonClicked() {
        self.onShowAllButtonClick?()
    }
}

extension ExploreStepikAcademyBlockHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.headerContainerView.addSubview(self.headerImageView)
        self.headerContainerView.addSubview(self.titleLabel)
        self.addSubview(self.headerContainerView)

        self.addSubview(self.descriptionLabel)
        self.addSubview(self.moreButton)
    }

    func makeConstraints() {
        self.headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(self.appearance.headerMinHeight)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.trailing.equalTo(self.headerImageView.snp.leading).offset(-self.appearance.titleLabelInsets.right)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.titleLabelInsets.bottom)
            make.centerY.equalToSuperview()
        }

        self.headerImageView.translatesAutoresizingMaskIntoConstraints = false
        self.headerImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-self.appearance.headerImageViewInsets.right)
            make.bottom.equalToSuperview()
            make.width.equalTo(self.appearance.headerImageViewWidth)
        }

        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.headerContainerView.snp.bottom).offset(self.appearance.descriptionLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.descriptionLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.descriptionLabelInsets.right)
        }

        self.moreButton.translatesAutoresizingMaskIntoConstraints = false
        self.moreButton.snp.makeConstraints { make in
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(self.appearance.moreButtonInsets.top)
            make.leading.equalTo(self.descriptionLabel.snp.leading)
            make.bottom.equalToSuperview().offset(-self.appearance.moreButtonInsets.bottom)
            make.trailing.lessThanOrEqualTo(self.descriptionLabel.snp.trailing)
        }
    }
}
