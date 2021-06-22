import SnapKit
import UIKit

extension CourseRevenueHeaderView {
    struct Appearance {
        let incomeViewInsets = LayoutInsets.default

        let disclaimerLabelFont = UIFont.systemFont(ofSize: 12)
        let disclaimerLabelTextColor = UIColor.stepikMaterialSecondaryText
    }
}

final class CourseRevenueHeaderView: UIView {
    let appearance: Appearance

    private lazy var incomeView = CourseRevenueIncomeView()

    private lazy var disclaimerLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.disclaimerLabelFont
        label.textColor = self.appearance.disclaimerLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.incomeViewInsets.top
            + self.incomeView.intrinsicContentSize.height
            + self.appearance.incomeViewInsets.bottom
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: height
        )
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

    func configure(viewModel: CourseRevenueHeaderViewModel) {
        self.incomeView.configure(viewModel: viewModel)
        self.disclaimerLabel.text = viewModel.disclaimerText
    }
}

extension CourseRevenueHeaderView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.incomeView)
    }

    func makeConstraints() {
        self.incomeView.translatesAutoresizingMaskIntoConstraints = false
        self.incomeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.incomeViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.incomeViewInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.incomeViewInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.incomeViewInsets.right)
        }
    }
}
