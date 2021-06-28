import SnapKit
import UIKit

extension CourseRevenueIncomeItemView {
    struct Appearance {
        let imageViewSize = CGSize(width: 32, height: 32)
        let imageViewInsets = LayoutInsets(left: 16)

        let expandContentControlSize = CGSize(width: 16, height: 16)
        let expandContentControlInsets = LayoutInsets(right: 16)
        let expandContentTapProxyViewSize = CGSize(width: 32, height: 32)

        let titleLabelFont = Typography.caption1Font
        let titleLabelTextColor = UIColor.stepikMaterialSecondaryText

        let priceLabelFont = UIFont.systemFont(ofSize: 22, weight: .semibold)
        let priceLabelTextColor = UIColor.stepikMaterialPrimaryText

        let detailsPriceLabelFont = UIFont.systemFont(ofSize: 20)
        let detailsPriceLabelTextColor = UIColor.stepikMaterialPrimaryText

        let messageLabelFont = Typography.caption1Font
        let messageLabelTextColor = UIColor.stepikMaterialSecondaryText
        let messageLabelInsets = LayoutInsets.default

        let stackViewSpacing: CGFloat = 8

        let contentStackViewSpacing: CGFloat = 16
        let contentStackViewInsets = LayoutInsets.default
    }
}

final class CourseRevenueIncomeItemView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.priceLabelFont
        label.textColor = self.appearance.priceLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var expandContentControl = ExpandContentControl()
    private lazy var expandContentTapProxyView = TapProxyView(targetView: self.expandContentControl)

    private lazy var detailsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var detailsPriceLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.detailsPriceLabelFont
        label.textColor = self.appearance.detailsPriceLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.messageLabelFont
        label.textColor = self.appearance.messageLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    private lazy var detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.contentStackViewSpacing
        return stackView
    }()

    private let shouldShowExpandContentControl: Bool

    var shouldShowDetails: Bool {
        didSet {
            self.updateDetailsVisibility()
        }
    }

    var style: Style {
        didSet {
            self.updateStyle()
        }
    }

    var titleText: String? {
        didSet {
            self.titleLabel.text = self.titleText
        }
    }

    var priceText: String? {
        didSet {
            self.priceLabel.text = self.priceText
        }
    }

    var detailsTitleText: String? {
        didSet {
            self.detailsTitleLabel.text = self.detailsTitleText
        }
    }

    var detailsPriceText: String? {
        didSet {
            self.detailsPriceLabel.text = self.detailsPriceText
        }
    }

    var messageText: String? {
        didSet {
            self.messageLabel.text = self.messageText
        }
    }

    var onExpandContentControlClick: (() -> Void)? {
        get {
            self.expandContentControl.onClick
        }
        set {
            self.expandContentControl.onClick = newValue
        }
    }

    override var intrinsicContentSize: CGSize {
        let contentStackViewHeight = self.contentStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            .height
        let height = self.appearance.contentStackViewInsets.top
            + max(contentStackViewHeight, self.appearance.imageViewSize.height)
            + self.appearance.contentStackViewInsets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        shouldShowExpandContentControl: Bool,
        shouldShowDetails: Bool,
        style: Style
    ) {
        self.appearance = appearance
        self.shouldShowExpandContentControl = shouldShowExpandContentControl
        self.shouldShowDetails = shouldShowDetails
        self.style = style

        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let convertedPoint = self.convert(point, to: self.expandContentTapProxyView)
        return self.expandContentTapProxyView.hitTest(convertedPoint, with: event)
    }

    private func updateDetailsVisibility() {
        self.detailsStackView.isHidden = !self.shouldShowDetails
    }

    private func updateStyle() {
        self.imageView.image = self.style.icon

        switch self.style {
        case .income, .info:
            self.messageLabel.isHidden = true
            self.contentStackView.isHidden = false

            if self.shouldShowExpandContentControl {
                self.expandContentControl.isHidden = false
            }
        case .empty:
            self.messageLabel.isHidden = false
            self.contentStackView.isHidden = true

            if self.shouldShowExpandContentControl {
                self.expandContentControl.reset()
                self.expandContentControl.isHidden = true
            }
        }
    }

    enum Style {
        case income
        case info
        case empty

        fileprivate var icon: UIImage? {
            switch self {
            case .income:
                return UIImage(named: "course-revenue-header-income")
            case .info:
                return UIImage(named: "course-revenue-header-info")
            case .empty:
                return UIImage(named: "course-revenue-header-empty")
            }
        }
    }
}

extension CourseRevenueIncomeItemView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateStyle()
        self.updateDetailsVisibility()
    }

    func addSubviews() {
        self.addSubview(self.imageView)

        self.addSubview(self.contentStackView)
        self.contentStackView.addArrangedSubview(self.titleStackView)
        self.contentStackView.addArrangedSubview(self.detailsStackView)

        self.titleStackView.addArrangedSubview(self.titleLabel)
        self.titleStackView.addArrangedSubview(self.priceLabel)

        self.detailsStackView.addArrangedSubview(self.detailsTitleLabel)
        self.detailsStackView.addArrangedSubview(self.detailsPriceLabel)

        if self.shouldShowExpandContentControl {
            self.addSubview(self.expandContentControl)
            self.addSubview(self.expandContentTapProxyView)
        }

        self.addSubview(self.messageLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.imageViewInsets.left)
            make.size.equalTo(self.appearance.imageViewSize)
            make.centerY.equalTo(self.titleStackView.snp.centerY)
        }

        if self.shouldShowExpandContentControl {
            self.expandContentControl.translatesAutoresizingMaskIntoConstraints = false
            self.expandContentControl.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-self.appearance.expandContentControlInsets.right)
                make.size.equalTo(self.appearance.expandContentControlSize)
                make.centerY.equalTo(self.titleStackView.snp.centerY)
            }

            self.expandContentTapProxyView.translatesAutoresizingMaskIntoConstraints = false
            self.expandContentTapProxyView.snp.makeConstraints { make in
                make.size.equalTo(self.appearance.expandContentTapProxyViewSize)
                make.center.equalTo(self.expandContentControl.snp.center)
            }
        }

        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.contentStackViewInsets.top)
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.contentStackViewInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.contentStackViewInsets.bottom)

            if self.shouldShowExpandContentControl {
                make.trailing
                    .equalTo(self.expandContentControl.snp.leading)
                    .offset(-self.appearance.contentStackViewInsets.right)
            } else {
                make.trailing.equalToSuperview().offset(-self.appearance.contentStackViewInsets.right)
            }
        }

        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.messageLabelInsets.left)
            make.centerY.equalTo(self.imageView.snp.centerY)
        }
    }
}
