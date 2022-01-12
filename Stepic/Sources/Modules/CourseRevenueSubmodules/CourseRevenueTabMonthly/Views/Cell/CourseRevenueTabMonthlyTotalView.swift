import SnapKit
import UIKit

extension CourseRevenueTabMonthlyTotalView {
    struct Appearance {
        let cornerRadius: CGFloat = 6
        let borderWidth: CGFloat = 4

        let titleFont = Typography.headlineFont
        let titleTextColor = UIColor.stepikMaterialPrimaryText

        let insets = LayoutInsets.default
    }
}

final class CourseRevenueTabMonthlyTotalView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var rightDetailTitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()

    private lazy var gradientLayer = CAGradientLayer()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var rightDetailTitle: String? {
        didSet {
            self.rightDetailTitleLabel.text = self.rightDetailTitle
        }
    }

    var rightDetailAttributedTitle: NSAttributedString? {
        didSet {
            if let rightDetailAttributedTitle = self.rightDetailAttributedTitle {
                self.rightDetailTitleLabel.attributedText = rightDetailAttributedTitle
            } else {
                self.rightDetailTitleLabel.attributedText = nil
            }
        }
    }

    var rightDetailTitleLabelTextColor: UIColor { self.rightDetailTitleLabel.textColor }

    var style: Style = .yellowGreen {
        didSet {
            self.updateStyle()
        }
    }

    override var intrinsicContentSize: CGSize {
        let titleHeight = max(
            self.titleLabel.intrinsicContentSize.height,
            self.rightDetailTitleLabel.intrinsicContentSize.height
        )
        let height = self.appearance.insets.top + titleHeight + self.appearance.insets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
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

        self.gradientLayer.frame = self.bounds

        let shape = CAShapeLayer()
        shape.lineWidth = self.appearance.borderWidth
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.appearance.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        self.gradientLayer.mask = shape
    }

    private func updateStyle() {
        self.gradientLayer.colors = self.style.gradientColors.map(\.cgColor)
        self.rightDetailTitleLabel.textColor = self.style.rightDetailTitleTextColor
    }

    enum Style {
        case yellowGreen
        case green
        case red

        fileprivate var gradientColors: [UIColor] {
            switch self {
            case .yellowGreen:
                return [
                    UIColor(hex6: 0xFFDC71).withAlphaComponent(0.38),
                    UIColor(hex6: 0x83D683).withAlphaComponent(0.19)
                ]
            case .green:
                return [
                    .stepikGreenFixed.withAlphaComponent(0.12),
                    .stepikGreenFixed.withAlphaComponent(0.12)
                ]
            case .red:
                return [
                    .stepikDiscountPriceText.withAlphaComponent(0.12),
                    .stepikDiscountPriceText.withAlphaComponent(0.12)
                ]
            }
        }

        fileprivate var rightDetailTitleTextColor: UIColor {
            switch self {
            case .yellowGreen, .green:
                return .stepikMaterialPrimaryText
            case .red:
                return .stepikDiscountPriceText
            }
        }
    }
}

extension CourseRevenueTabMonthlyTotalView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.gradientLayer.frame = self.bounds
        self.layer.addSublayer(self.gradientLayer)

        self.updateStyle()
        self.roundAllCorners(radius: self.appearance.cornerRadius)
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.rightDetailTitleLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(self.appearance.insets.edgeInsets)
            make.trailing
                .lessThanOrEqualTo(self.rightDetailTitleLabel.snp.leading)
                .offset(self.appearance.insets.right / 2)
        }

        self.rightDetailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.rightDetailTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.rightDetailTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.rightDetailTitleLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(self.appearance.insets.edgeInsets)
        }
    }
}
