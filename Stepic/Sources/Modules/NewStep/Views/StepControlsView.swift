import SnapKit
import UIKit

extension StepControlsView {
    struct Appearance {
        let insets = LayoutInsets(top: 16, left: 16, right: 16)
        let spacing: CGFloat = 16

        let navigationButtonsSpacing: CGFloat = 16
        let navigationButtonsHeight: CGFloat = 44

        let submitButtonBackgroundColor = UIColor.stepicGreen
        let submitButtonHeight: CGFloat = 44
        let submitButtonTextColor = UIColor.white
        let submitButtonCornerRadius: CGFloat = 6
        let submitButtonFont = UIFont.systemFont(ofSize: 16)

        let commentsButtonHeight: CGFloat = 44
    }
}

final class StepControlsView: UIView {
    let appearance: Appearance

    private lazy var submitButton: UIButton = {
        let submitButton = UIButton(type: .system)
        submitButton.setTitleColor(self.appearance.submitButtonTextColor, for: .normal)
        submitButton.titleLabel?.font = self.appearance.submitButtonFont
        submitButton.setTitle("Отправить", for: .normal)
        submitButton.layer.cornerRadius = self.appearance.submitButtonCornerRadius
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = self.appearance.submitButtonBackgroundColor
        return submitButton
    }()

    private lazy var commentsButton: StepCommentsButton = {
        let button = StepCommentsButton()
        button.addTarget(self, action: #selector(self.commentsButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var navigationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.navigationButtonsSpacing
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private var navigationBottomConstraint: Constraint?
    private var navigationBottomCommentsConstraint: Constraint?

    override var intrinsicContentSize: CGSize {
        let stackViewSize = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.insets.top
                + stackViewSize.height
                + (self.navigationState == .none ? 0 : self.appearance.spacing)
                + (self.isCommentsButtonHidden ? 0 : self.appearance.commentsButtonHeight)
        )
    }

    var sizeWithAllControls: CGSize {
        let size = self.bounds.size
        return CGSize(
            width: size.width,
            height: self.appearance.insets.top
                + self.appearance.submitButtonHeight
                + self.appearance.spacing
                + self.appearance.commentsButtonHeight
        )
    }

    var commentsTitle: String? {
        didSet {
            self.commentsButton.title = self.commentsTitle
        }
    }

    var navigationState: NavigationState? {
        didSet {
            self.updateNavigationState()
            self.updateNavigationButtons()
        }
    }

    var isCommentsButtonHidden: Bool = false {
        didSet {
            self.updateCommentsButton()
        }
    }

    var onCommentsButtonClick: (() -> Void)?
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
    private func commentsButtonClicked() {
        self.onCommentsButtonClick?()
    }

    private func updateNavigationState() {
        self.navigationStackView.removeAllArrangedSubviews()

        if self.navigationStackView.superview != nil {
            self.stackView.removeArrangedSubview(self.navigationStackView)
            self.navigationStackView.removeFromSuperview()
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

        self.stackView.addArrangedSubview(self.navigationStackView)
    }

    private func updateCommentsButton() {
        if self.isCommentsButtonHidden {
            self.commentsButton.isHidden = true
        }

        if self.isCommentsButtonHidden {
            self.navigationBottomCommentsConstraint?.deactivate()
            self.navigationBottomConstraint?.activate()
        } else {
            self.navigationBottomCommentsConstraint?.activate()
            self.navigationBottomConstraint?.deactivate()
        }
    }

    private func updateNavigationButtons() {
        if self.navigationState == .none {
            self.navigationBottomCommentsConstraint?.update(offset: 0)
            self.navigationBottomConstraint?.update(offset: 0)
        } else {
            self.navigationBottomCommentsConstraint?.update(offset: -self.appearance.spacing)
            self.navigationBottomConstraint?.update(offset: -self.appearance.spacing)
        }
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
        self.addSubview(self.commentsButton)
    }

    func makeConstraints() {
        self.commentsButton.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.commentsButtonHeight)
        }

        self.submitButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.submitButtonHeight)
        }

        self.navigationStackView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.navigationButtonsHeight)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)

            self.navigationBottomCommentsConstraint = make.bottom
                .equalTo(self.commentsButton.snp.top)
                .offset(-self.appearance.spacing)
                .constraint

            self.navigationBottomConstraint = make.bottom
                .equalToSuperview()
                .offset(-self.appearance.spacing)
                .constraint
        }

        // Should be executed when all constraints set up
        self.updateCommentsButton()
        self.updateNavigationButtons()
    }
}
