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
        let textFieldHeight: CGFloat = 44
        let textFieldCornerRadius: CGFloat = 8
        let textFieldBorderWidth: CGFloat = 1
        let textFieldBorderColor = UIColor.stepikSeparator
        let textFieldInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let textFieldClearButtonInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)

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

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

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
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func revealInputButtonClicked() {
    }

    @objc
    private func textFieldTextChanged() {
        let text = self.textField.text ?? ""
        print(text)
    }
}

extension CourseInfoPurchaseModalPromoCodeView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.revealInputButton)
        self.stackView.addArrangedSubview(self.textField)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(self.appearance.stackViewInsets.edgeInsets)
        }

        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.textFieldHeight)
        }
    }
}
