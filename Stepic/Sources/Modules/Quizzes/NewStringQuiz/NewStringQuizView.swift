import SnapKit
import UIKit

protocol NewStringQuizViewDelegate: AnyObject {
    func newStringQuizView(_ view: NewStringQuizView, didUpdate text: String)
}

extension NewStringQuizView {
    struct Appearance {
        let spacing: CGFloat = 16
        let insets = LayoutInsets(left: 16, right: 16)

        let textFieldPlaceholderFont = UIFont.systemFont(ofSize: 16)
        let textFieldPlaceholderColor = UIColor.stepikPlaceholderText
        let textFieldTextColor = UIColor.stepikPrimaryText
        let textFieldHeight: CGFloat = 48

        let titleColor = UIColor.stepikPrimaryText
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)

        let textFieldBorderCornerRadius: CGFloat = 6
        let textFieldBorderWidth: CGFloat = 1
        let textFieldBorderColor = UIColor.stepikSeparator

        let statusMarkInsets = LayoutInsets(right: 16)
        let statusMarkSize = CGSize(width: 20, height: 20)

        let textFieldInsets = LayoutInsets(top: 1, left: 12, bottom: 1)
        let textFieldDefaultOffset: CGFloat = 12
        let textFieldMarkOffset: CGFloat = 52
    }
}

final class NewStringQuizView: UIView, TitlePresentable {
    let appearance: Appearance
    weak var delegate: NewStringQuizViewDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleColor
        label.font = self.appearance.titleFont
        return label
    }()

    private lazy var textField: TableInputTextField = {
        let field = TableInputTextField()
        field.placeholderColor = self.appearance.textFieldPlaceholderColor
        field.textColor = self.appearance.textFieldTextColor
        field.font = self.appearance.textFieldPlaceholderFont
        field.textInsets = UIEdgeInsets(
            top: self.appearance.textFieldInsets.top,
            left: self.appearance.textFieldInsets.left,
            bottom: self.appearance.textFieldInsets.bottom,
            right: self.appearance.textFieldDefaultOffset
        )
        field.roundAllCorners(
            radius: self.appearance.textFieldBorderCornerRadius,
            borderWidth: self.appearance.textFieldBorderWidth,
            borderColor: self.appearance.textFieldBorderColor
        )
        field.addTarget(self, action: #selector(self.textFieldTextChanged), for: .editingChanged)

        // Disable features
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.smartDashesType = .no
        field.smartQuotesType = .no
        field.smartInsertDeleteType = .no

        return field
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [self.titleLabelContainerView, self.textFieldContainerView]
        )
        stackView.spacing = self.appearance.spacing
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var correctMarkImageView = UIImageView(image: UIImage(named: "quiz-mark-correct"))
    private lazy var wrongMarkImageView = UIImageView(image: UIImage(named: "quiz-mark-wrong"))

    private lazy var textFieldContainerView = UIView()
    private lazy var titleLabelContainerView = UIView()

    var title: String? {
        get {
            self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
            self.titleLabelContainerView.isHidden = newValue?.isEmpty ?? true
        }
    }

    var placeholder: String? {
        didSet {
            self.textField.placeholder = self.placeholder
        }
    }

    var text: String? {
        didSet {
            self.textField.text = self.text
        }
    }

    var state: NewStringQuizViewModel.State? {
        didSet {
            self.updateState()
        }
    }

    var isTextFieldEnabled: Bool {
        get {
            self.textField.isEnabled
        }
        set {
            self.textField.isEnabled = newValue
        }
    }

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

    private func updateState() {
        self.correctMarkImageView.isHidden = self.state != .correct
        self.wrongMarkImageView.isHidden = self.state != .wrong

        self.textField.textInsets = UIEdgeInsets(
            top: self.appearance.textFieldInsets.top,
            left: self.appearance.textFieldInsets.left,
            bottom: self.appearance.textFieldInsets.bottom,
            right: self.state == nil ? self.appearance.textFieldDefaultOffset : self.appearance.textFieldMarkOffset
        )
    }

    @objc
    private func textFieldTextChanged() {
        self.delegate?.newStringQuizView(self, didUpdate: self.textField.text ?? "")
    }
}

extension NewStringQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateState()
    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.textFieldContainerView.addSubview(self.textField)
        self.textFieldContainerView.addSubview(self.correctMarkImageView)
        self.textFieldContainerView.addSubview(self.wrongMarkImageView)
        self.titleLabelContainerView.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.height.equalTo(self.appearance.textFieldHeight)
        }

        self.correctMarkImageView.translatesAutoresizingMaskIntoConstraints = false
        self.correctMarkImageView.snp.makeConstraints { make in
            make.trailing.equalTo(self.textField.snp.trailing).offset(-self.appearance.statusMarkInsets.right)
            make.centerY.equalTo(self.textField.snp.centerY)
            make.size.equalTo(self.appearance.statusMarkSize)
        }

        self.wrongMarkImageView.translatesAutoresizingMaskIntoConstraints = false
        self.wrongMarkImageView.snp.makeConstraints { make in
            make.trailing.equalTo(self.textField.snp.trailing).offset(-self.appearance.statusMarkInsets.right)
            make.centerY.equalTo(self.textField.snp.centerY)
            make.size.equalTo(self.appearance.statusMarkSize)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
