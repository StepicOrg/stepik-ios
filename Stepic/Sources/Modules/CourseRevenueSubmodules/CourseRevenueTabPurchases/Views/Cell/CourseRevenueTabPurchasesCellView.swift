import SnapKit
import UIKit

extension CourseRevenueTabPurchasesCellView {
    struct Appearance {
        let logoImageViewSize = CGSize(width: 24, height: 24)
        let logoImageViewInsets = LayoutInsets.default

        let dateLabelTextColor = UIColor.stepikMaterialSecondaryText
        let dateLabelFont = Typography.caption1Font
        let dateLabelInsets = LayoutInsets.default

        let titleLabelTextColor = UIColor.stepikMaterialPrimaryText
        let titleLabelFont = Typography.bodyFont
        let titleLabelInsets = LayoutInsets(top: 8, left: 16, bottom: 8, right: 16)

        let subtitleLabelTextColor = UIColor.stepikMaterialDisabledText
        let subtitleLabelFont = Typography.caption1Font
        let subtitleLabelInsets = LayoutInsets(top: 8, left: 16, bottom: 16, right: 16)

        let rightDetailSubtitleLabelTextColor = UIColor.stepikMaterialSecondaryText
        let rightDetailSubtitleLabelFont = Typography.caption1Font
        let rightDetailSubtitleLabelInsets = LayoutInsets(top: 16, left: 16, bottom: 8, right: 16)

        let rightDetailTitleLabelTextColor = UIColor.stepikMaterialPrimaryText
        let rightDetailTitleLabelRefundedTextColor = UIColor.stepikDiscountPriceText
        let rightDetailTitleLabelFont = Typography.headlineFont
        let rightDetailTitleLabelInsets = LayoutInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
}

final class CourseRevenueTabPurchasesCellView: UIView {
    let appearance: Appearance

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.dateLabelFont
        label.textColor = self.appearance.dateLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 0

        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.titleLabelTapped)
        )
        tapGestureRecognizer.numberOfTapsRequired = 1
        label.addGestureRecognizer(tapGestureRecognizer)
        label.isUserInteractionEnabled = true

        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleLabelFont
        label.textColor = self.appearance.subtitleLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var rightDetailSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.rightDetailSubtitleLabelFont
        label.textColor = self.appearance.rightDetailSubtitleLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var rightDetailTitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.rightDetailTitleLabelFont
        label.textColor = self.appearance.rightDetailTitleLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private var subtitleBottomConstraint: Constraint?

    var onTitleLabelTapped: (() -> Void)?

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

    func configure(viewModel: CourseRevenueTabPurchasesViewModel?) {
        let isRefunded = viewModel?.isRefunded ?? false

        let logoImage: UIImage? = {
            if isRefunded {
                return UIImage(named: "course-revenue-transaction-refund")
            } else if viewModel?.isZLinkUsed ?? false {
                return UIImage(named: "course-revenue-transaction-z-link")
            }
            return UIImage(named: "course-revenue-transaction-logo")
        }()

        self.logoImageView.image = logoImage
        self.dateLabel.text = viewModel?.formattedDate
        self.titleLabel.text = viewModel?.buyerName

        self.subtitleLabel.text = viewModel?.promoCodeName
        let subtitleBottomOffset = viewModel?.promoCodeName?.isEmpty ?? true
            ? self.appearance.subtitleLabelInsets.bottom / 2
            : self.appearance.subtitleLabelInsets.bottom
        self.subtitleBottomConstraint?.update(offset: -subtitleBottomOffset)

        if isRefunded {
            self.rightDetailSubtitleLabel.text = NSLocalizedString("CourseRevenueTransactionRefundedTitle", comment: "")
        } else if let formattedPaymentAmount = viewModel?.formattedPaymentAmount {
            self.rightDetailSubtitleLabel.attributedText = FormatterHelper.priceCourseRevenueToAttributedString(
                price: formattedPaymentAmount,
                priceFont: self.appearance.rightDetailSubtitleLabelFont,
                priceColor: self.appearance.rightDetailSubtitleLabelTextColor
            )
        } else {
            self.rightDetailSubtitleLabel.attributedText = nil
        }

        self.rightDetailTitleLabel.textColor = isRefunded
            ? self.appearance.rightDetailTitleLabelRefundedTextColor
            : self.appearance.rightDetailTitleLabelTextColor
        if let formattedAmount = viewModel?.formattedAmount {
            self.rightDetailTitleLabel.attributedText = FormatterHelper.priceCourseRevenueToAttributedString(
                price: formattedAmount,
                priceFont: self.appearance.rightDetailTitleLabelFont,
                priceColor: self.rightDetailTitleLabel.textColor
            )
        } else {
            self.rightDetailTitleLabel.attributedText = nil
        }
    }

    @objc
    private func titleLabelTapped() {
        self.onTitleLabelTapped?()
    }
}

extension CourseRevenueTabPurchasesCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.logoImageView)
        self.addSubview(self.dateLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.titleLabel)
        self.addSubview(self.rightDetailSubtitleLabel)
        self.addSubview(self.rightDetailTitleLabel)
    }

    func makeConstraints() {
        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.logoImageViewInsets.left)
            make.size.equalTo(self.appearance.logoImageViewSize)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }

        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.dateLabelInsets.top)
            make.leading.equalTo(self.logoImageView.snp.trailing).offset(self.appearance.dateLabelInsets.left)
            make.trailing
                .lessThanOrEqualTo(self.rightDetailSubtitleLabel.snp.leading)
                .offset(-self.appearance.dateLabelInsets.right)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(self.appearance.titleLabelInsets.top)
            make.leading.equalTo(self.logoImageView.snp.trailing).offset(self.appearance.titleLabelInsets.left)
            make.bottom.equalTo(self.subtitleLabel.snp.top).offset(-self.appearance.titleLabelInsets.bottom)
            make.trailing
                .lessThanOrEqualTo(self.rightDetailTitleLabel.snp.leading)
                .offset(-self.appearance.titleLabelInsets.right)
        }

        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.logoImageView.snp.trailing).offset(self.appearance.subtitleLabelInsets.left)
            self.subtitleBottomConstraint = make.bottom
                .equalToSuperview()
                .offset(-self.appearance.subtitleLabelInsets.bottom)
                .constraint
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.subtitleLabelInsets.right)
        }

        self.rightDetailSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.rightDetailSubtitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.rightDetailSubtitleLabelInsets.top)
            make.bottom
                .equalTo(self.rightDetailTitleLabel.snp.top)
                .offset(-self.appearance.rightDetailSubtitleLabelInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.rightDetailSubtitleLabelInsets.right)
        }

        self.rightDetailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.rightDetailTitleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.rightDetailTitleLabelInsets.right)
        }
    }
}
