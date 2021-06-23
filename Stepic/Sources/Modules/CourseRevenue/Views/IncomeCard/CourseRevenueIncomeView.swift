import SnapKit
import UIKit

extension CourseRevenueIncomeView {
    struct Appearance {
        let backgroundColor = UIColor.dynamic(light: .white, dark: .stepikSecondaryBackground)
        let cornerRadius: CGFloat = 8

        let shadowColor = UIColor.black
        let shadowOffset = CGSize(width: 0, height: 1)
        let shadowRadius: CGFloat = 4.0
        let shadowOpacity: Float = 0.1

        let separatorBackgroundColor = UIColor.dynamic(
            light: .onSurface.withAlphaComponent(0.04),
            dark: .stepikSeparator
        )
        let separatorViewHeight: CGFloat = 1
    }

    enum Animation {
        static let expandContentAnimationDuration: TimeInterval = 0.33
    }
}

final class CourseRevenueIncomeView: UIView {
    let appearance: Appearance

    private lazy var monthItemView: CourseRevenueIncomeItemView = {
        let view = CourseRevenueIncomeItemView(
            shouldShowExpandContentControl: true,
            shouldShowDetails: false,
            style: .income
        )
        view.onExpandContentControlClick = self.handleExpandContentControlClicked
        return view
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorBackgroundColor
        return view
    }()

    private lazy var totalItemView: CourseRevenueIncomeItemView = {
        let view = CourseRevenueIncomeItemView(
            shouldShowExpandContentControl: false,
            shouldShowDetails: true,
            style: .info
        )
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    private var isContentExpanded = false
    var onExpandContentButtonClick: ((Bool) -> Void)?

    override var intrinsicContentSize: CGSize {
        let contentStackViewHeight = self.contentStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            .height
        return CGSize(width: UIView.noIntrinsicMetric, height: contentStackViewHeight)
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

        self.backgroundColor = self.appearance.backgroundColor
        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.masksToBounds = true

        self.layer.shadowColor = self.appearance.shadowColor.cgColor
        self.layer.shadowOffset = self.appearance.shadowOffset
        self.layer.shadowRadius = self.appearance.shadowRadius
        self.layer.shadowOpacity = self.appearance.shadowOpacity
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.layer.cornerRadius
        ).cgPath
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let convertedPoint = self.convert(point, to: self.monthItemView)

        if self.monthItemView.bounds.contains(convertedPoint) {
            if let targetView = self.monthItemView.hitTest(convertedPoint, with: event) {
                return targetView
            }
        }

        return nil
    }

    func configure(viewModel: CourseRevenueHeaderViewModel) {
        self.monthItemView.titleText = viewModel.monthIncomeDate
        self.monthItemView.priceText = viewModel.monthIncomeValue
        self.monthItemView.detailsTitleText = viewModel.monthTurnoverDate
        self.monthItemView.detailsPriceText = viewModel.monthTurnoverValue

        self.totalItemView.titleText = viewModel.totalIncomeDate
        self.totalItemView.priceText = viewModel.totalIncomeValue
        self.totalItemView.detailsTitleText = viewModel.totalTurnoverDate
        self.totalItemView.detailsPriceText = viewModel.totalTurnoverValue
    }

    private func handleExpandContentControlClicked() {
        let shouldExpandContent = !self.isContentExpanded
        self.isContentExpanded.toggle()

        self.onExpandContentButtonClick?(shouldExpandContent)

        UIView.animate(withDuration: Animation.expandContentAnimationDuration) {
            self.separatorView.isHidden = !shouldExpandContent
            self.totalItemView.isHidden = !shouldExpandContent
        }
    }
}

extension CourseRevenueIncomeView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.separatorView.isHidden = true
        self.totalItemView.isHidden = true
    }

    func addSubviews() {
        self.addSubview(self.contentStackView)
        self.contentStackView.addArrangedSubview(self.monthItemView)
        self.contentStackView.addArrangedSubview(self.separatorView)
        self.contentStackView.addArrangedSubview(self.totalItemView)
    }

    func makeConstraints() {
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorViewHeight)
        }
    }
}
