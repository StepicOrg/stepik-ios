import SnapKit
import UIKit

extension NewProfileActivityView {
    struct Appearance {
        let pinsMapViewHeight: CGFloat = 166
        let backgroundColor = UIColor.stepikBackground
    }
}

final class NewProfileActivityView: UIView {
    let appearance: Appearance

    private lazy var currentStreakView = NewProfileActivityCurrentStreakView()

    private lazy var pinsMapView = PinsMapView()

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.currentStreakView.intrinsicContentSize.height + self.appearance.pinsMapViewHeight
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

    func configure(viewModel: NewProfileActivityViewModel) {
        self.currentStreakView.didSolveToday = viewModel.didSolveToday
        self.currentStreakView.text = viewModel.streakText
        self.pinsMapView.buildMonths(viewModel.pins)
    }
}

extension NewProfileActivityView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.currentStreakView)
        self.addSubview(self.pinsMapView)
    }

    func makeConstraints() {
        self.currentStreakView.translatesAutoresizingMaskIntoConstraints = false
        self.currentStreakView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.pinsMapView.translatesAutoresizingMaskIntoConstraints = false
        self.pinsMapView.snp.makeConstraints { make in
            make.top.equalTo(self.currentStreakView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.pinsMapViewHeight)
        }
    }
}
