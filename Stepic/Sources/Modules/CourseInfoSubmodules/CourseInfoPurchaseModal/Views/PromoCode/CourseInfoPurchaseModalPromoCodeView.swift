import SnapKit
import UIKit

extension CourseInfoPurchaseModalPromoCodeView {
    struct Appearance {
        let revealInputButtonFont = Typography.bodyFont
        let revealInputButtonTintColor = UIColor.stepikGreenFixed
        let revealInputButtonImageSize = CGSize(width: 15, height: 15)
        let revealInputButtonImageInsets = UIEdgeInsets(top: 4, left: 8, bottom: 0, right: 0)
        let revealInputButtonInsets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 16)

        let textFieldFont = Typography.bodyFont
        let textFieldPlaceholderColor = UIColor.stepikMaterialDisabledText
        let textFieldTextColor = UIColor.stepikMaterialPrimaryText
        let textFieldCornerRadius: CGFloat = 8
        let textFieldBorderWidth: CGFloat = 1
        let textFieldBorderColor = UIColor.stepikSeparator
        let textFieldInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let textFieldClearButtonInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)

        let inputStackViewHeight: CGFloat = 44
        let rightDetailViewWidth: CGFloat = 52

        let statusLabelFont = Typography.caption1Font

        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = LayoutInsets(horizontal: 16)
    }
}

final class CourseInfoPurchaseModalPromoCodeView: UIView {
    let appearance: Appearance

    private lazy var revealInputButton: ImageButton = {
        let button = ImageButton()
        button.tintColor = self.appearance.revealInputButtonTintColor
        button.title = NSLocalizedString("CourseInfoPurchaseModalRevealPromoCodeInputTitle", comment: "")
        button.font = self.appearance.revealInputButtonFont
        button.image = UIImage(named: "code-quiz-arrow-down")?.withRenderingMode(.alwaysTemplate)
        button.imageSize = self.appearance.revealInputButtonImageSize
        button.imageInsets = self.appearance.revealInputButtonImageInsets
        button.imagePosition = .right
        button.addTarget(self, action: #selector(self.revealInputButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var textField: TableInputTextField = {
        let textField = TableInputTextField()
        textField.placeholderColor = self.appearance.textFieldPlaceholderColor
        textField.placeholder = NSLocalizedString("CourseInfoPurchaseModalInputPlaceholder", comment: "")
        textField.textColor = self.appearance.textFieldTextColor
        textField.font = self.appearance.textFieldFont
        textField.textInsets = self.appearance.textFieldInsets
        textField.setRoundedCorners(
            cornerRadius: self.appearance.textFieldCornerRadius,
            borderWidth: self.appearance.textFieldBorderWidth,
            borderColor: self.appearance.textFieldBorderColor
        )
        textField.clearButtonInsets = self.appearance.textFieldClearButtonInsets
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(self.textFieldTextChanged), for: .editingChanged)

        // Disable features
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.smartInsertDeleteType = .no

        return textField
    }()

    private lazy var rightDetailView = CourseInfoPurchaseModalPromoCodeRightDetailView()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.statusLabelFont
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    // textField -> rightDetailView
    private lazy var inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    var state = State.idle {
        didSet {
            if oldValue != self.state {
                self.updateState()
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        let stackViewIntrinsicContentSize = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: UIView.noIntrinsicMetric, height: stackViewIntrinsicContentSize.height)
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

        self.updateState()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateState() {
        switch self.state {
        case .idle:
            self.revealInputButton.isHidden = false
            self.inputStackView.isHidden = true
            self.rightDetailView.isHidden = true
            self.statusLabel.isHidden = true
        case .typing:
            self.revealInputButton.isHidden = true
            self.inputStackView.isHidden = false
            self.statusLabel.isHidden = true

            self.rightDetailView.isUserInteractionEnabled = true
            self.rightDetailView.viewState = .idle

            self.isUserInteractionEnabled = true
        case .loading:
            self.statusLabel.isHidden = false

            self.rightDetailView.isUserInteractionEnabled = false
            self.rightDetailView.viewState = .loading

            self.isUserInteractionEnabled = false
        case .error:
            self.statusLabel.isHidden = false

            self.rightDetailView.isUserInteractionEnabled = false
            self.rightDetailView.viewState = .error

            self.isUserInteractionEnabled = true
        case .success:
            self.statusLabel.isHidden = false

            self.rightDetailView.isUserInteractionEnabled = false
            self.rightDetailView.viewState = .success

            self.isUserInteractionEnabled = true
        }

        self.statusLabel.text = self.state.statusLabelText
        if let statusLabelTextColor = self.state.statusLabelTextColor {
            self.statusLabel.textColor = statusLabelTextColor
        }
    }

    @objc
    private func revealInputButtonClicked() {
        self.state = .typing
    }

    @objc
    private func rightDetailViewClicked() {
        guard self.state == .typing else {
            return
        }

        self.state = .loading
    }

    @objc
    private func textFieldTextChanged() {
        let text = self.textField.text ?? ""
        self.rightDetailView.isHidden = text.isEmpty
    }

    enum State {
        case idle
        case typing
        case loading
        case error
        case success

        fileprivate var statusLabelText: String? {
            switch self {
            case .idle, .typing:
                return nil
            case .loading:
                return NSLocalizedString("CourseInfoPurchaseModalPromoCodeStatusLoading", comment: "")
            case .error:
                return NSLocalizedString("CourseInfoPurchaseModalPromoCodeStatusError", comment: "")
            case .success:
                return NSLocalizedString("CourseInfoPurchaseModalPromoCodeStatusSuccess", comment: "")
            }
        }

        fileprivate var statusLabelTextColor: UIColor? {
            switch self {
            case .idle, .typing:
                return nil
            case .loading:
                return .stepikVioletFixed
            case .error:
                return .stepikDiscountPriceText
            case .success:
                return .stepikGreenFixed
            }
        }
    }
}

extension CourseInfoPurchaseModalPromoCodeView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.rightDetailView.addTarget(self, action: #selector(self.rightDetailViewClicked), for: .touchUpInside)
    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.revealInputButton)
        self.stackView.addArrangedSubview(self.inputStackView)
        self.stackView.addArrangedSubview(self.statusLabel)

        self.inputStackView.addArrangedSubview(self.textField)
        self.inputStackView.addArrangedSubview(self.rightDetailView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(self.appearance.stackViewInsets.edgeInsets)
        }

        self.inputStackView.translatesAutoresizingMaskIntoConstraints = false
        self.inputStackView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.inputStackViewHeight)
        }

        self.rightDetailView.translatesAutoresizingMaskIntoConstraints = false
        self.rightDetailView.snp.makeConstraints { make in
            make.width.equalTo(self.appearance.rightDetailViewWidth)
        }
    }
}
