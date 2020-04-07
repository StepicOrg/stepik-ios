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

        let separatorColor = UIColor.dynamic(light: UIColor(hex6: 0xEAECF0), dark: .stepikSeparator)
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
                + (self.discussionsButtonTopSeparatorView.isHidden ? 0 : self.appearance.separatorHeight)
                + self.appearance.discussionThreadButtonHeight
                + (self.discussionsButtonBottomSeparatorView.isHidden ? 0 : self.appearance.separatorHeight)
                + (self.solutionsButton.isHidden ? 0 : self.appearance.discussionThreadButtonHeight)
                + (self.solutionsButtonBottomSeparatorView.isHidden ? 0 : self.appearance.separatorHeight)
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
                + self.appearance.separatorHeight
                + self.appearance.discussionThreadButtonHeight
                + self.appearance.separatorHeight
                + self.appearance.discussionThreadButtonHeight
                + self.appearance.separatorHeight
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

    @objc
    private func solutionsButtonClicked() {
        self.onSolutionsButtonClick?()
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

    private func updateSolutionsButtonVisibility() {
        self.solutionsButton.isHidden = self.solutionsTitle?.isEmpty ?? true
        self.solutionsButtonBottomSeparatorView.isHidden = self.solutionsButton.isHidden

        self.discussionsButtonTopSeparatorView.isHidden = self.solutionsButton.isHidden
        self.discussionsButtonBottomSeparatorView.isHidden = self.solutionsButton.isHidden
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
