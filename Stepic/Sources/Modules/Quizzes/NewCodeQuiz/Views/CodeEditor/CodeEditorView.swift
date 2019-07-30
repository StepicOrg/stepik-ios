import SnapKit
import UIKit

protocol CodeEditorViewDelegate: class {
    func codeEditorViewDidChange(_ codeEditorView: CodeEditorView)
    func codeEditorViewDidRequestSuggestionPresentationController(_ codeEditorView: CodeEditorView) -> UIViewController?
}

final class CodeEditorView: UIView {
    weak var delegate: CodeEditorViewDelegate?

    private lazy var codeTextView: CodeTextView = {
        let codeTextView = CodeTextView()
        codeTextView.delegate = self

        codeTextView.autocapitalizationType = .none
        codeTextView.autocorrectionType = .no
        codeTextView.spellCheckingType = .no

        if #available(iOS 11.0, *) {
            codeTextView.smartDashesType = .no
            codeTextView.smartQuotesType = .no
            codeTextView.smartInsertDeleteType = .no
        }

        return codeTextView
    }()

    private let codePlaygroundManager = CodePlaygroundManager()
    // Uses by codePlaygroundManager for analysis between current code and old one (suggestions & completions).
    private var oldCode: String?

    private let elementsSize: CodeQuizElementsSize = DeviceInfo.current.isPad ? .big : .small
    private var tabSize = 0

    var code: String? {
        get {
            return self.codeTextView.text
        }
        set {
            self.codeTextView.text = newValue
            if self.oldCode == nil {
                self.oldCode = newValue
            }
        }
    }

    var codeTemplate: String? {
        didSet {
            self.tabSize = self.codePlaygroundManager.countTabSize(text: self.codeTemplate ?? "")
        }
    }

    var language: CodeLanguage? {
        didSet {
            self.codeTextView.language = self.language?.highlightr
            self.setupAccessoryView(isEditable: self.isEnabled)
        }
    }

    var theme: Theme? {
        didSet {
            if let theme = theme {
                self.codeTextView.updateTheme(name: theme.name, font: theme.font)
            }
        }
    }

    var isEnabled = true {
        didSet {
            self.codeTextView.isEditable = self.isEnabled
            self.setupAccessoryView(isEditable: self.isEnabled)
        }
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAccessoryView(isEditable: Bool) {
        defer {
            self.codeTextView.reloadInputViews()
        }

        guard let language = self.language, isEditable else {
            self.codeTextView.inputAccessoryView = nil
            return
        }

        self.codeTextView.inputAccessoryView = InputAccessoryBuilder.buildAccessoryView(
            size: self.elementsSize.elements.toolbar,
            language: language,
            tabAction: { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.codePlaygroundManager.insertAtCurrentPosition(
                    symbols: String(repeating: " ", count: strongSelf.tabSize),
                    textView: strongSelf.codeTextView
                )
            },
            insertStringAction: { [weak self] symbols in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.codePlaygroundManager.insertAtCurrentPosition(
                    symbols: symbols,
                    textView: strongSelf.codeTextView
                )
                strongSelf.analyzeCodeAndComplete()
            },
            hideKeyboardAction: { [weak self] in
                self?.codeTextView.resignFirstResponder()
            }
        )
    }

    private func analyzeCodeAndComplete() {
        guard let language = self.language,
              let viewController = self.delegate?.codeEditorViewDidRequestSuggestionPresentationController(self) else {
            return
        }

        self.codePlaygroundManager.analyzeAndComplete(
            textView: self.codeTextView,
            previousText: self.oldCode ?? "",
            language: language,
            tabSize: self.tabSize,
            inViewController: viewController,
            suggestionsDelegate: self
        )

        self.oldCode = self.code
    }

    struct Theme {
        let name: String
        let font: UIFont
    }
}

extension CodeEditorView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.codeTextView)
    }

    func makeConstraints() {
        self.codeTextView.translatesAutoresizingMaskIntoConstraints = false
        self.codeTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension CodeEditorView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "\n"
            DispatchQueue.main.async {
                textView.selectedRange = NSRange(location: 0, length: 0)
            }
        }

        self.analyzeCodeAndComplete()
        self.delegate?.codeEditorViewDidChange(self)
    }

    @available(iOS 10.0, *)
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        return false
    }

    @available(iOS 10.0, *)
    func textView(
        _ textView: UITextView,
        shouldInteractWith textAttachment: NSTextAttachment,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        return false
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return false
    }

    func textView(
        _ textView: UITextView,
        shouldInteractWith textAttachment: NSTextAttachment,
        in characterRange: NSRange
    ) -> Bool {
        return false
    }
}

extension CodeEditorView: CodeSuggestionDelegate {
    func didSelectSuggestion(suggestion: String, prefix: String) {
        guard self.codeTextView.isEditable else {
            return
        }

        self.codeTextView.becomeFirstResponder()

        let symbols = String(suggestion[suggestion.index(suggestion.startIndex, offsetBy: prefix.count)...])
        self.codePlaygroundManager.insertAtCurrentPosition(symbols: symbols, textView: self.codeTextView)

        self.analyzeCodeAndComplete()
    }

    var suggestionsSize: CodeSuggestionsSize {
        return self.elementsSize.elements.suggestions
    }
}
