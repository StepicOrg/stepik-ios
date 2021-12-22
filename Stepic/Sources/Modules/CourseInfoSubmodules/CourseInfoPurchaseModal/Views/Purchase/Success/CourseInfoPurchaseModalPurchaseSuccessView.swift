import SnapKit
import UIKit

extension CourseInfoPurchaseModalPurchaseSuccessView {
    struct Appearance {
        let iconImageViewSize = CGSize(width: 56, height: 56)
        let iconImageViewTintColor = UIColor.stepikGreenFixed

        let statusLabelFont = UIFont.systemFont(ofSize: 15, weight: .medium)
        let statusLabelTextColor = UIColor.stepikMaterialPrimaryText

        let actionButtonHeight: CGFloat = 44
        let actionButtonTextColor = UIColor.white
        let actionButtonBackgroundColor = UIColor.stepikGreenFixed

        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = LayoutInsets(horizontal: 16)
    }
}

final class CourseInfoPurchaseModalPurchaseSuccessView: UIView {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let image = UIImage(named: "CourseInfoPurchaseModalPurchaseSuccess")?.withRenderingMode(.alwaysTemplate)
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
        label.text = NSLocalizedString("CourseInfoPurchaseModalPurchaseSuccessStatusTitle", comment: "")
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

    private lazy var actionButton: CourseInfoPurchaseModalActionButton = {
        var appearance = CourseInfoPurchaseModalActionButton.Appearance()
        appearance.textLabelTextColor = self.appearance.actionButtonTextColor
        appearance.backgroundColor = self.appearance.actionButtonBackgroundColor
        let button = CourseInfoPurchaseModalActionButton(appearance: appearance)
        button.text = NSLocalizedString("CourseInfoPurchaseModalPurchaseSuccessStartLearningTitle", comment: "")
        button.addTarget(self, action: #selector(self.actionButtonClicked), for: .touchUpInside)
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

    var onStartLearningClick: (() -> Void)?

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
    private func actionButtonClicked() {
        self.onStartLearningClick?()
    }
}

extension CourseInfoPurchaseModalPurchaseSuccessView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.iconImageView)
        self.stackView.addArrangedSubview(self.statusLabel)
        self.stackView.addArrangedSubview(self.coverView)
        self.stackView.addArrangedSubview(SeparatorView())
        self.stackView.addArrangedSubview(self.actionButton)
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

        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.actionButtonHeight)
        }
    }
}
