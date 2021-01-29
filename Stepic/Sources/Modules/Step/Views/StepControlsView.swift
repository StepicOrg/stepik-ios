import SnapKit
import UIKit

extension StepControlsView {
    struct Appearance {
        let insets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)
        let spacing: CGFloat = 16

        let navigationButtonsSpacing: CGFloat = 16
        let navigationButtonsHeight: CGFloat = 44

        let discussionThreadButtonHeight: CGFloat = 44
        let statisticsViewHeight: CGFloat = 44

        let separatorColor = UIColor.dynamic(light: UIColor.stepikShadowFixed, dark: .stepikSeparator)
        let separatorHeight: CGFloat = 1.0
    }
}

final class StepControlsView: UIView {
    let appearance: Appearance

    private lazy var statisticsView: StepStatisticsView = {
        let view = StepStatisticsView()
        view.isTopSeparatorVisible = true
        return view
    }()

    private lazy var discussionsButtonTopSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        view.isHidden = true
        return view
    }()

    private lazy var discussionsButton: StepDiscussionThreadButton = {
        let button = StepDiscussionThreadButton(threadItem: .discussions)
        button.addTarget(self, action: #selector(self.discussionsButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var discussionsButtonBottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        view.isHidden = true
        return view
    }()

    private lazy var solutionsButton: StepDiscussionThreadButton = {
        let button = StepDiscussionThreadButton(threadItem: .solutions)
        button.addTarget(self, action: #selector(self.solutionsButtonClicked), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var solutionsButtonBottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        view.isHidden = true
        return view
    }()

    private lazy var bottomControlsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.statisticsView,
                self.discussionsButtonTopSeparatorView,
                self.discussionsButton,
                self.discussionsButtonBottomSeparatorView,
                self.solutionsButton,
                self.solutionsButtonBottomSeparatorView
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    private lazy var nextStepButton: UIButton = {
        let button = NextStepButton()
        button.addTarget(self, action: #selector(self.nextStepClicked), for: .touchUpInside)
        return button
    }()

    private lazy var nextStepButtonContainerView = UIView()

    private lazy var unitNavigationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.navigationButtonsSpacing
        return stackView
    }()

    private lazy var unitNavigationContainerView = UIView()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.nextStepButtonContainerView,
                self.unitNavigationContainerView,
                self.bottomControlsStackView
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        let stackViewSize = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: UIView.noIntrinsicMetric, height: self.appearance.insets.top + stackViewSize.height)
    }

    var sizeWithAllControls: CGSize {
        let size = self.bounds.size
        return CGSize(
            width: size.width,
            height: self.appearance.insets.top
                + self.appearance.navigationButtonsHeight
                + self.appearance.spacing
                + self.appearance.navigationButtonsHeight
                + self.appearance.spacing
                + self.appearance.statisticsViewHeight
                + self.appearance.separatorHeight
                + self.appearance.discussionThreadButtonHeight
                + self.appearance.separatorHeight
                + self.appearance.discussionThreadButtonHeight
                + self.appearance.separatorHeight
        )
    }

    var hasNextStepButton: Bool = false {
        didSet {
            self.nextStepButtonContainerView.isHidden = !self.hasNextStepButton
        }
    }

    var unitNavigationState: UnitNavigationState? {
        didSet {
            self.updateUnitNavigationState()
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

    var solutionsTitle: String? {
        didSet {
            self.solutionsButton.title = self.solutionsTitle
            self.updateSolutionsButtonVisibility()
        }
    }

    var isSolutionsButtonEnabled: Bool = true {
        didSet {
            self.solutionsButton.isEnabled = self.isSolutionsButtonEnabled
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
    var onSolutionsButtonClick: (() -> Void)?
    var onPreviousUnitButtonClick: (() -> Void)?
    var onNextUnitButtonClick: (() -> Void)?
    var onNextStepButtonClick: (() -> Void)?

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
    private func nextStepClicked() {
        self.onNextStepButtonClick?()
    }

    @objc
    private func previousUnitButtonClicked() {
        self.onPreviousUnitButtonClick?()
    }

    @objc
    private func nextUnitButtonClicked() {
        self.onNextUnitButtonClick?()
    }

    @objc
    private func discussionsButtonClicked() {
        self.onDiscussionsButtonClick?()
    }

    @objc
    private func solutionsButtonClicked() {
        self.onSolutionsButtonClick?()
    }

    private func updateUnitNavigationState() {
        self.unitNavigationStackView.removeAllArrangedSubviews()

        if self.unitNavigationContainerView.superview != nil {
            self.stackView.removeArrangedSubview(self.unitNavigationContainerView)
            self.unitNavigationContainerView.removeFromSuperview()
        }

        if self.unitNavigationState == .none {
            return
        }

        let previousButton = StepNavigationButton(type: .previous, isCentered: self.unitNavigationState == .previous)
        previousButton.addTarget(self, action: #selector(self.previousUnitButtonClicked), for: .touchUpInside)
        if self.unitNavigationState == .both {
            previousButton.isTitleHidden = true
        }

        let nextButton = StepNavigationButton(type: .next, isCentered: self.unitNavigationState == .next)
        nextButton.addTarget(self, action: #selector(self.nextUnitButtonClicked), for: .touchUpInside)

        if self.unitNavigationState == .previous || self.unitNavigationState == .both {
            self.unitNavigationStackView.addArrangedSubview(previousButton)
        }

        if self.unitNavigationState == .next || self.unitNavigationState == .both {
            self.unitNavigationStackView.addArrangedSubview(nextButton)
        }

        self.stackView.insertArrangedSubview(self.unitNavigationContainerView, at: 1)
    }

    private func updateStatisticsVisibility() {
        self.statisticsView.isHidden = self.passedByCount == nil && self.correctRatio == nil
    }

    private func updateSolutionsButtonVisibility() {
        self.solutionsButton.isHidden = self.solutionsTitle?.isEmpty ?? true
        self.solutionsButtonBottomSeparatorView.isHidden = self.solutionsButton.isHidden

        self.discussionsButtonTopSeparatorView.isHidden = self.solutionsButton.isHidden
        self.discussionsButtonBottomSeparatorView.isHidden = self.solutionsButton.isHidden
    }

    // MARK: Enum

    enum UnitNavigationState {
        case both
        case next
        case previous
    }
}

extension StepControlsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.hasNextStepButton = false
        self.updateUnitNavigationState()
    }

    func addSubviews() {
        self.addSubview(self.stackView)
        self.nextStepButtonContainerView.addSubview(self.nextStepButton)
        self.unitNavigationContainerView.addSubview(self.unitNavigationStackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }

        self.nextStepButton.translatesAutoresizingMaskIntoConstraints = false
        self.nextStepButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.navigationButtonsHeight)
        }

        self.unitNavigationContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.unitNavigationContainerView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.navigationButtonsHeight)
        }

        self.unitNavigationStackView.translatesAutoresizingMaskIntoConstraints = false
        self.unitNavigationStackView.snp.makeConstraints { make in
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
            make.height.equalTo(self.appearance.discussionThreadButtonHeight)
        }

        self.solutionsButton.translatesAutoresizingMaskIntoConstraints = false
        self.solutionsButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.discussionThreadButtonHeight)
        }

        self.discussionsButtonTopSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.discussionsButtonTopSeparatorView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
        }

        self.discussionsButtonBottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.discussionsButtonBottomSeparatorView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
        }

        self.solutionsButtonBottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.solutionsButtonBottomSeparatorView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }
}
