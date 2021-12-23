import SnapKit
import UIKit

extension CourseInfoPurchaseModalPurchaseErrorView {
    struct Appearance {
        let iconImageViewSize = CGSize(width: 56, height: 56)
        let iconImageViewTintColor = UIColor.stepikDiscountPriceText

        let statusLabelFont = UIFont.systemFont(ofSize: 15, weight: .medium)
        let statusLabelTextColor = UIColor.stepikMaterialPrimaryText

        let restoreButtonHeight: CGFloat = 44
        let restoreButtonTextColor = UIColor.white
        let restoreButtonBackgroundColor = UIColor.stepikGreenFixed

        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = LayoutInsets(horizontal: 16)
    }
}

final class CourseInfoPurchaseModalPurchaseErrorView: UIView {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let image = UIImage(named: "CourseInfoPurchaseModalPurchaseFail")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.iconImageViewTintColor
        return imageView
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.statusLabelFont
        label.textColor = self.appearance.statusLabelTextColor
        label.numberOfLines = 0
        label.text = NSLocalizedString("CourseInfoPurchaseModalPurchaseErrorStatusTitle", comment: "")
        label.textAlignment = .center
        return label
    }()

    private lazy var coverView: CourseInfoPurchaseModalCourseCoverView = {
        var appearance = CourseInfoPurchaseModalCourseCoverView.Appearance()
        appearance.coverImageViewInsets = LayoutInsets(top: 16, left: 0)
        appearance.titleInsets = LayoutInsets(left: 16, right: 0)
        let view = CourseInfoPurchaseModalCourseCoverView(appearance: appearance)
        return view
    }()

    private lazy var feedbackView: CourseInfoPurchaseModalPurchaseErrorFeedbackView = {
        let view = CourseInfoPurchaseModalPurchaseErrorFeedbackView()
        view.onLinkClick = { [weak self] url in
            guard let strongSelf = self else {
                return
            }

            guard url.absoluteString.contains("support.stepik") else {
                return
            }

            strongSelf.onContactSupportClick?()
        }
        return view
    }()

    private lazy var restoreButton: CourseInfoPurchaseModalActionButton = {
        var appearance = CourseInfoPurchaseModalActionButton.Appearance()
        appearance.textLabelTextColor = self.appearance.restoreButtonTextColor
        appearance.backgroundColor = self.appearance.restoreButtonBackgroundColor
        let button = CourseInfoPurchaseModalActionButton(appearance: appearance)
        button.text = NSLocalizedString("CourseInfoPurchaseModalPurchaseErrorRestoreTitle", comment: "")
        button.addTarget(self, action: #selector(self.restoreButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    var courseCoverURL: URL? {
        didSet {
            self.coverView.coverURL = self.courseCoverURL
        }
    }

    var courseTitle: String? {
        didSet {
            self.coverView.titleText = self.courseTitle
        }
    }

    var onRestorePurchaseClick: (() -> Void)?
    var onContactSupportClick: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        let stackViewIntrinsicContentSize = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: UIView.noIntrinsicMetric, height: stackViewIntrinsicContentSize.height)
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

    @objc
    private func restoreButtonClicked() {
        self.onRestorePurchaseClick?()
    }
}

extension CourseInfoPurchaseModalPurchaseErrorView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.iconImageView)
        self.stackView.addArrangedSubview(self.statusLabel)
        self.stackView.addArrangedSubview(self.coverView)
        self.stackView.addArrangedSubview(self.feedbackView)
        self.stackView.addArrangedSubview(SeparatorView())
        self.stackView.addArrangedSubview(self.restoreButton)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(self.appearance.stackViewInsets.edgeInsets)
        }

        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.iconImageViewSize)
            make.centerX.equalToSuperview()
        }

        self.restoreButton.translatesAutoresizingMaskIntoConstraints = false
        self.restoreButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.restoreButtonHeight)
        }
    }
}
