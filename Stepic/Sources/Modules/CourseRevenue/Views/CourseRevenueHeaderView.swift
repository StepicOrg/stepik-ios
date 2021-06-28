import SnapKit
import UIKit

extension CourseRevenueHeaderView {
    struct Appearance {
        let incomeViewInsets = LayoutInsets.default

        let disclaimerLabelFont = Typography.caption1Font
        let disclaimerLabelTextColor = UIColor.stepikMaterialSecondaryText
        let disclaimerLabelInsets = LayoutInsets.default
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

    var onSummaryButtonClick: ((Bool) -> Void)? {
        get {
            self.incomeView.onExpandContentButtonClick
        }
        set {
            self.incomeView.onExpandContentButtonClick = newValue
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.incomeViewInsets.top
            + self.incomeView.intrinsicContentSize.height
            + self.appearance.disclaimerLabelInsets.top
            + self.disclaimerLabel.intrinsicContentSize.height
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

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let convertedPoint = self.convert(point, to: self.incomeView)

        if self.incomeView.bounds.contains(convertedPoint) {
            if let targetView = self.incomeView.hitTest(convertedPoint, with: event) {
                return targetView
            }
        }

        return nil
    }

    func configure(viewModel: CourseRevenueEmptyHeaderViewModel) {
        self.incomeView.configure(viewModel: viewModel)
        self.disclaimerLabel.text = viewModel.disclaimerText
    }

    func configure(viewModel: CourseRevenueHeaderViewModel) {
        self.incomeView.configure(viewModel: viewModel)
        self.disclaimerLabel.text = viewModel.disclaimerText
    }

    func setLoading(_ isLoading: Bool) {
        [self.incomeView, self.disclaimerLabel].forEach { $0.isHidden = isLoading }

        if isLoading {
            self.skeleton.viewBuilder = { CourseRevenueHeaderSkeletonView() }
            self.skeleton.show()
        } else {
            self.skeleton.hide()
        }
    }
}

extension CourseRevenueHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.incomeView)
        self.addSubview(self.disclaimerLabel)
    }

    func makeConstraints() {
        self.incomeView.translatesAutoresizingMaskIntoConstraints = false
        self.incomeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.incomeViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.incomeViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.incomeViewInsets.right)
        }

        self.disclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.disclaimerLabel.snp.makeConstraints { make in
            make.top.equalTo(self.incomeView.snp.bottom).offset(self.appearance.disclaimerLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.disclaimerLabelInsets.left)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-self.appearance.disclaimerLabelInsets.right)
        }
    }
}
