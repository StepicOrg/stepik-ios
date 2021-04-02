import SnapKit
import UIKit

extension StepikAcademyCourseListWidgetView {
    struct Appearance {
        let titleLabelFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let titleLabelTextColor = UIColor.stepikMaterialPrimaryText
        let titleLabelNumberOfLines = DeviceInfo.current.isSmallDiagonal ? 3 : 2
        let titleLabelInsets = LayoutInsets(inset: 16)

        let durationLabelFont = Typography.caption1Font
        let durationLabelTextColor = UIColor.stepikMaterialSecondaryText
        let durationLabelInsets = LayoutInsets(top: 8, bottom: 2, right: 16)

        let discountLabelFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let discountLabelTextColor = UIColor.dynamic(light: .stepikVioletFixed, dark: .stepikViolet05Fixed)
        let discountLabelInsets = LayoutInsets(left: 16, bottom: 16)

        let priceLabelFont = Typography.caption1Font
        let priceLabelTextColor = UIColor.stepikMaterialDisabledText
        let priceLabelInsets = LayoutInsets(left: 8, right: 16)
    }
}

final class StepikAcademyCourseListWidgetView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = self.appearance.titleLabelNumberOfLines
        return label
    }()

    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.durationLabelFont
        label.textColor = self.appearance.durationLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var discountLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.discountLabelFont
        label.textColor = self.appearance.discountLabelTextColor
        label.numberOfLines = 1
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

    func configure(viewModel: StepikAcademyCourseListWidgetViewModel) {
        self.titleLabel.text = viewModel.title
        self.durationLabel.text = "6 недель"
        self.discountLabel.text = "6000 R"
        self.priceLabel.attributedText = NSAttributedString(
            string: "35000 R",
            attributes: [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue
            ]
        )
    }
}

extension StepikAcademyCourseListWidgetView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.durationLabel)
        self.addSubview(self.discountLabel)
        self.addSubview(self.priceLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleLabelInsets.right)
        }

        self.durationLabel.translatesAutoresizingMaskIntoConstraints = false
        self.durationLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(self.titleLabel.snp.bottom).offset(self.appearance.durationLabelInsets.top)
            make.leading.equalTo(self.discountLabel.snp.leading)
            make.bottom.equalTo(self.discountLabel.snp.top).offset(-self.appearance.durationLabelInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.durationLabelInsets.right)
        }

        self.discountLabel.translatesAutoresizingMaskIntoConstraints = false
        self.discountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.discountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.discountLabelInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.discountLabelInsets.bottom)
        }

        self.priceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.priceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.discountLabel.snp.trailing).offset(self.appearance.priceLabelInsets.left)
            make.bottom.equalTo(self.discountLabel.snp.bottom)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.priceLabelInsets.right)
        }
    }
}
