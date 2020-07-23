import SnapKit
import UIKit

extension NewProfileUserActivityView {
    struct Appearance {
        let longestStreakLabelFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let longestStreakLabelTextColor = UIColor.stepikSystemSecondaryText
        let longestStreakLabelInsets = LayoutInsets(top: 8)

        let pinsMapViewHeight: CGFloat = 166
        let backgroundColor = UIColor.stepikSecondaryGroupedBackground
    }
}

final class NewProfileUserActivityView: UIView {
    let appearance: Appearance

    private lazy var currentStreakView = NewProfileUserActivityCurrentStreakView()
    private lazy var longestStreakLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.longestStreakLabelFont
        label.textColor = self.appearance.longestStreakLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var pinsMapView = PinsMapView()

    private var longestStreakLabelTopToBottomOfCurrentStreakViewConstraint: Constraint?
    private var longestStreakLabelTopToSuperview: Constraint?

    override var intrinsicContentSize: CGSize {
        let currentStreakViewHeight = self.currentStreakView.isHidden
            ? 0
            : self.currentStreakView.intrinsicContentSize.height
        let longestStreakLabelHeightWithInsets = self.longestStreakLabel.isHidden
            ? 0
            : (self.appearance.longestStreakLabelInsets.top + self.longestStreakLabel.intrinsicContentSize.height)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: currentStreakViewHeight + longestStreakLabelHeightWithInsets + self.appearance.pinsMapViewHeight
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

        self.pinsMapView.buildMonths(UserActivity.emptyYearPins)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: NewProfileUserActivityViewModel) {
        self.currentStreakView.didSolveToday = viewModel.didSolveToday
        self.currentStreakView.text = viewModel.currentStreakText
        self.currentStreakView.isHidden = self.currentStreakView.text?.isEmpty ?? true

        self.longestStreakLabel.text = viewModel.longestStreakText
        self.longestStreakLabel.isHidden = self.longestStreakLabel.text?.isEmpty ?? true

        if self.currentStreakView.isHidden {
            self.longestStreakLabelTopToSuperview?.activate()
            self.longestStreakLabelTopToBottomOfCurrentStreakViewConstraint?.deactivate()
        } else {
            self.longestStreakLabelTopToBottomOfCurrentStreakViewConstraint?.activate()
            self.longestStreakLabelTopToSuperview?.deactivate()
        }

        self.pinsMapView.buildMonths(viewModel.pins)
    }
}

extension NewProfileUserActivityView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.currentStreakView)
        self.addSubview(self.longestStreakLabel)
        self.addSubview(self.pinsMapView)
    }

    func makeConstraints() {
        self.currentStreakView.translatesAutoresizingMaskIntoConstraints = false
        self.currentStreakView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.longestStreakLabel.translatesAutoresizingMaskIntoConstraints = false
        self.longestStreakLabel.snp.makeConstraints { make in
            self.longestStreakLabelTopToBottomOfCurrentStreakViewConstraint = make.top
                .equalTo(self.currentStreakView.snp.bottom)
                .offset(self.appearance.longestStreakLabelInsets.top)
                .constraint
            self.longestStreakLabelTopToSuperview = make.top.equalToSuperview().constraint
            self.longestStreakLabelTopToSuperview?.deactivate()
            make.leading.trailing.equalToSuperview()
        }

        self.pinsMapView.translatesAutoresizingMaskIntoConstraints = false
        self.pinsMapView.snp.makeConstraints { make in
            make.top.equalTo(self.longestStreakLabel.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.pinsMapViewHeight)
        }
    }
}
