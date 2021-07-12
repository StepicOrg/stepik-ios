import SnapKit
import UIKit

extension CourseRevenueTabMonthlyTotalView {
    struct Appearance {
        let cornerRadius: CGFloat = 6
        let borderWidth: CGFloat = 2

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

        self.addSubviews()
        self.makeConstraints()

        self.setRoundedCorners(
            cornerRadius: self.appearance.cornerRadius,
            borderWidth: self.appearance.borderWidth,
            borderColor: .stepikGreenFixed
        )
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseRevenueTabMonthlyTotalView: ProgrammaticallyInitializableViewProtocol {
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
