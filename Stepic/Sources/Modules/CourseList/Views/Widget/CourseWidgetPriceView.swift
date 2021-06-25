import SnapKit
import UIKit

extension CourseWidgetPriceView {
    struct Appearance {
        let textFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let priceFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let discountPriceFont = UIFont.systemFont(ofSize: 12, weight: .regular)

        let callToActionTextColor = UIColor.stepikGreen
        let disabledTextColor = UIColor.stepikMaterialDisabledText
        let priceTextColor = UIColor.dynamic(light: .stepikVioletFixed, dark: .stepikViolet05Fixed)
        let discountPriceTextColor = UIColor.stepikDiscountPriceText

        let spacing: CGFloat = 4
    }
}

final class CourseWidgetPriceView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()

    private var titleLabelTopToSuperviewConstraint: Constraint?
    private var titleLabelTopToBottomOfSubtitleConstraint: Constraint?

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

    func configure(viewModel: CourseWidgetPriceViewModel) {
        if viewModel.isEnrolled {
            self.setSubtitleLabelHidden(true)

            self.titleLabel.font = self.appearance.textFont
            self.titleLabel.textColor = self.appearance.disabledTextColor
            self.titleLabel.text = NSLocalizedString("CourseWidgetEnrolled", comment: "")
        } else if !viewModel.isPaid {
            self.setSubtitleLabelHidden(true)

            self.titleLabel.font = self.appearance.textFont
            self.titleLabel.textColor = self.appearance.callToActionTextColor
            self.titleLabel.text = viewModel.priceString
        } else if let discountPriceString = viewModel.discountPriceString {
            self.setSubtitleLabelHidden(false)

            self.titleLabel.font = self.appearance.priceFont
            self.titleLabel.textColor = self.appearance.discountPriceTextColor
            self.titleLabel.text = discountPriceString

            self.subtitleLabel.font = self.appearance.discountPriceFont
            self.subtitleLabel.textColor = self.appearance.priceTextColor
            self.subtitleLabel.attributedText = NSAttributedString(
                string: viewModel.priceString ?? "",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: self.appearance.priceTextColor
                ]
            )
        } else {
            self.setSubtitleLabelHidden(true)

            self.titleLabel.font = self.appearance.priceFont
            self.titleLabel.textColor = self.appearance.priceTextColor
            self.titleLabel.text = viewModel.priceString
        }
    }

    private func setSubtitleLabelHidden(_ isHidden: Bool) {
        self.subtitleLabel.isHidden = isHidden

        if isHidden {
            self.titleLabelTopToSuperviewConstraint?.activate()
            self.titleLabelTopToBottomOfSubtitleConstraint?.deactivate()
        } else {
            self.titleLabelTopToSuperviewConstraint?.deactivate()
            self.titleLabelTopToBottomOfSubtitleConstraint?.activate()
        }
    }
}

extension CourseWidgetPriceView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.titleLabel.snp.makeConstraints { make in
            self.titleLabelTopToSuperviewConstraint = make.top.equalToSuperview().constraint
            self.titleLabelTopToBottomOfSubtitleConstraint = make
                .top
                .equalTo(self.subtitleLabel.snp.bottom)
                .offset(self.appearance.spacing)
                .constraint
            self.titleLabelTopToBottomOfSubtitleConstraint?.deactivate()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
