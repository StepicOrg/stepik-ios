import SnapKit
import UIKit

extension StepControlsView {
    struct Appearance {
        let insets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)
        let spacing: CGFloat = 16

        let navigationButtonsSpacing: CGFloat = 16
        let navigationButtonsHeight: CGFloat = 44

        let discussionsButtonHeight: CGFloat = 44
        let statisticsViewHeight: CGFloat = 44
    }
}

final class StepControlsView: UIView {
    let appearance: Appearance

    private lazy var statisticsView: StepStatisticsView = {
        let view = StepStatisticsView()
        view.isTopSeparatorVisible = true
        return view
    }()

    private lazy var discussionsButton: StepDiscussionsButton = {
        let button = StepDiscussionsButton()
        button.addTarget(self, action: #selector(self.discussionsButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var bottomControlsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.statisticsView, self.discussionsButton])
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    private lazy var navigationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.navigationButtonsSpacing
        return stackView
    }()

    private lazy var navigationContainerView = UIView()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.navigationContainerView, self.bottomControlsStackView])
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        let stackViewSize = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.insets.top
                + stackViewSize.height
                + (self.navigationState == .none ? 0 : self.appearance.spacing)
                + self.appearance.statisticsViewHeight
                + self.appearance.discussionsButtonHeight
        )
    }

    var sizeWithAllControls: CGSize {
        let size = self.bounds.size
        return CGSize(
            width: size.width,
            height: self.appearance.insets.top
                + self.appearance.navigationButtonsHeight
                + self.appearance.spacing
                + self.appearance.statisticsViewHeight
                + self.appearance.discussionsButtonHeight
        )
    }

    var navigationState: NavigationState? {
        didSet {
            self.updateNavigationState()
        }
    }

    var discussionsTitle: String? {
        didSet {
            self.discussionsButton.title = self.discussionsTitle
        }
    }

    var isDiscussionsButtonEnabled: Bool = true {
        didSet {
            self.discussionsButton.isEnabled = self.isDiscussionsButtonEnabled
        }
    }

    var passedByCount: Int? {
        didSet {
            self.statisticsView.passedByCount = self.passedByCount
            self.updateStatisticsVisibility()
        }
    }

    var correctRatio: Float? {
        didSet {
            self.statisticsView.correctRatio = self.correctRatio
            self.updateStatisticsVisibility()
        }
    }

    var onDiscussionsButtonClick: (() -> Void)?
    var onPreviousButtonClick: (() -> Void)?
    var onNextButtonClick: (() -> Void)?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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
        self.invalidateIntrinsicContentSize()
    }

    // MARK: Private API

    @objc
    private func previousButtonClicked() {
        self.onPreviousButtonClick?()
    }

    @objc
    private func nextButtonClicked() {
        self.onNextButtonClick?()
    }

    @objc
    private func discussionsButtonClicked() {
        self.onDiscussionsButtonClick?()
    }

    private func updateNavigationState() {
        self.navigationStackView.removeAllArrangedSubviews()

        if self.navigationContainerView.superview != nil {
            self.stackView.removeArrangedSubview(self.navigationContainerView)
            self.navigationContainerView.removeFromSuperview()
        }

        if self.navigationState == .none {
            return
        }

        let previousButton = StepNavigationButton(type: .previous, isCentered: self.navigationState == .previous)
        previousButton.addTarget(self, action: #selector(self.previousButtonClicked), for: .touchUpInside)
        if self.navigationState == .both {
            previousButton.isTitleHidden = true
        }

        let nextButton = StepNavigationButton(type: .next, isCentered: self.navigationState == .next)
        nextButton.addTarget(self, action: #selector(self.nextButtonClicked), for: .touchUpInside)

        if self.navigationState == .previous || self.navigationState == .both {
            self.navigationStackView.addArrangedSubview(previousButton)
        }

        if self.navigationState == .next || self.navigationState == .both {
            self.navigationStackView.addArrangedSubview(nextButton)
        }

        self.stackView.insertArrangedSubview(self.navigationContainerView, at: 0)
    }

    private func updateStatisticsVisibility() {
        self.statisticsView.isHidden = self.passedByCount == nil && self.correctRatio == nil
    }

    // MARK: Enum

    enum NavigationState {
        case both
        case next
        case previous
    }
}

extension StepControlsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateNavigationState()
    }

    func addSubviews() {
        self.addSubview(self.stackView)
        self.navigationContainerView.addSubview(self.navigationStackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }

        self.navigationContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.navigationContainerView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.navigationButtonsHeight)
        }

        self.navigationStackView.translatesAutoresizingMaskIntoConstraints = false
        self.navigationStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.top.bottom.equalToSuperview()
        }

        self.statisticsView.translatesAutoresizingMaskIntoConstraints = false
        self.statisticsView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.statisticsViewHeight)
        }

        self.discussionsButton.translatesAutoresizingMaskIntoConstraints = false
        self.discussionsButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.discussionsButtonHeight)
        }
    }
}
