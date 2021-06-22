import SnapKit
import UIKit

extension CourseRevenueTabPurchasesCellView {
    struct Appearance {
        let textLabelTextColor = UIColor.stepikMaterialPrimaryText
        let textLabelFont = Typography.bodyFont
        let textLabelInsets = LayoutInsets.default
    }
}

final class CourseRevenueTabPurchasesCellView: UIView {
    let appearance: Appearance

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textLabelFont
        label.textColor = self.appearance.textLabelTextColor
        label.numberOfLines = 0
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

    func configure(viewModel: CourseRevenueTabPurchasesViewModel?) {
        self.textLabel.text = viewModel?.title
    }
}

extension CourseRevenueTabPurchasesCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.textLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.textLabelInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.textLabelInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.textLabelInsets.right)
        }
    }
}
