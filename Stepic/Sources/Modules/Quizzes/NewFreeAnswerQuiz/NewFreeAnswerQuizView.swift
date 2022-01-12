import SnapKit
import UIKit

protocol NewFreeAnswerQuizViewDelegate: AnyObject {
    func newFreeAnswerQuizView(_ view: NewFreeAnswerQuizView, didUpdate text: String)
}

extension NewFreeAnswerQuizView {
    struct Appearance {
        let spacing: CGFloat = 16
        let insets = LayoutInsets(left: 16, right: 16)

        let titleColor = UIColor.stepikPrimaryText
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)

        let textFieldPlaceholderFont = UIFont.systemFont(ofSize: 16)
        let textFieldPlaceholderColor = UIColor.stepikPlaceholderText
        let textFieldTextColor = UIColor.stepikPrimaryText

        let textFieldBorderCornerRadius: CGFloat = 6
        let textFieldBorderWidth: CGFloat = 1
        let textFieldBorderColor = UIColor.stepikSeparator

        let textFieldInsets = UIEdgeInsets(top: 12, left: 12, bottom: 36, right: 12)
    }
}

final class NewFreeAnswerQuizView: UIView, TitlePresentable {
    let appearance: Appearance
    weak var delegate: NewFreeAnswerQuizViewDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleColor
        label.font = self.appearance.titleFont
        return label
    }()

    private lazy var textView: TableInputTextView = {
        let textView = TableInputTextView()
        textView.textInsets = self.appearance.textFieldInsets
        textView.roundAllCorners(
            radius: self.appearance.textFieldBorderCornerRadius,
            borderWidth: self.appearance.textFieldBorderWidth,
            borderColor: self.appearance.textFieldBorderColor
        )
        textView.textColor = self.appearance.textFieldTextColor
        textView.placeholderColor = self.appearance.textFieldPlaceholderColor
        textView.font = self.appearance.textFieldPlaceholderFont

        textView.delegate = self

        // Disable features
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.smartInsertDeleteType = .no

        return textView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.titleLabelContainerView, self.textFieldContainerView])
        stackView.spacing = self.appearance.spacing
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var titleLabelContainerView = UIView()
    private lazy var textFieldContainerView = UIView()

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
            self.textView.placeholder = self.placeholder
        }
    }

    var text: String? {
        didSet {
            self.textView.text = self.text
        }
    }

    var isTextViewEnabled: Bool {
        get {
            self.textView.isEditable
        }
        set {
            self.textView.isEditable = newValue
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
}

extension NewFreeAnswerQuizView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)
        self.textFieldContainerView.addSubview(self.textView)
        self.titleLabelContainerView.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension NewFreeAnswerQuizView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.newFreeAnswerQuizView(self, didUpdate: textView.text)
    }
}
