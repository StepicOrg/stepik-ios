import SnapKit
import UIKit

extension CourseRevenueHeaderView {
    struct Appearance {
        let incomeViewInsets = LayoutInsets.default
    }
}

final class CourseRevenueHeaderView: UIView {
    let appearance: Appearance

    private lazy var incomeView = CourseRevenueIncomeView()

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
