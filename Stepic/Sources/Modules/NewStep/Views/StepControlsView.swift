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
    let navigationState: NavigationState

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

    private lazy var navigationPreviousButton: StepNavigationButton = {
        var button = StepNavigationButton(type: .previous, isCentered: self.navigationState == .previous)
        if self.navigationState == .both {
            button.isTitleHidden = true
        }
        return button
    }()

    private lazy var navigationNextButton: StepNavigationButton = {
        var button = StepNavigationButton(type: .next, isCentered: self.navigationState == .next)
        return button
    }()

    private lazy var commentsButton = StepCommentsButton()

    private lazy var navigationStackView: UIStackView = {
        let stackView = UIStackView()

        if self.navigationState == .previous || self.navigationState == .both {
            stackView.addArrangedSubview(self.navigationPreviousButton)
        }

        if self.navigationState == .next || self.navigationState == .both {
            stackView.addArrangedSubview(self.navigationNextButton)
        }

        stackView.axis = .horizontal
        stackView.spacing = self.appearance.navigationButtonsSpacing
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [self.navigationStackView]
        )
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
                + self.appearance.spacing
                + self.appearance.commentsButtonHeight
        )
    }

    init(frame: CGRect = .zero, navigationState: NavigationState, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        self.navigationState = navigationState
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

    // MARK: Enum

    enum NavigationState {
        case both
        case next
        case previous
    }
}

extension StepControlsView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)
        self.addSubview(self.commentsButton)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.submitButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.submitButtonHeight)
        }

        self.navigationStackView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.navigationButtonsHeight)
        }

        self.commentsButton.snp.makeConstraints { make in
            make.top.equalTo(self.stackView.snp.bottom).offset(self.appearance.spacing)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.commentsButtonHeight)
        }
    }
}
