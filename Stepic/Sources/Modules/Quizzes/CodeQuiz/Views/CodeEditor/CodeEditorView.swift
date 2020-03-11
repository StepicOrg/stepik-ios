import SnapKit
import UIKit

protocol CodeEditorViewDelegate: AnyObject {
    func codeEditorViewDidChange(_ codeEditorView: CodeEditorView)
    func codeEditorView(_ codeEditorView: CodeEditorView, beginEditing editing: Bool)
    func codeEditorViewDidBeginEditing(_ codeEditorView: CodeEditorView)
    func codeEditorViewDidEndEditing(_ codeEditorView: CodeEditorView)
    func codeEditorViewDidRequestSuggestionPresentationController(_ codeEditorView: CodeEditorView) -> UIViewController?
}

extension CodeEditorViewDelegate {
    func codeEditorViewDidChange(_ codeEditorView: CodeEditorView) {}

    func codeEditorView(_ codeEditorView: CodeEditorView, beginEditing editing: Bool) {}

    func codeEditorViewDidBeginEditing(_ codeEditorView: CodeEditorView) {}

    func codeEditorViewDidEndEditing(_ codeEditorView: CodeEditorView) {}

    func codeEditorViewDidRequestSuggestionPresentationController(
        _ codeEditorView: CodeEditorView
    ) -> UIViewController? {
        nil
    }
}

extension CodeEditorView {
    struct Appearance {
        var languageNameLabelLayoutInsets = LayoutInsets(top: 8, right: 16)
        let languageNameLabelTextColor = UIColor.mainDark
        let languageNameLabelBackgroundColor = UIColor(hex6: 0xF6F6F6).withAlphaComponent(0.75)
        let languageNameLabelFont = UIFont.systemFont(ofSize: 10)
        let languageNameLabelInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        let languageNameLabelCornerRadius: CGFloat = 10
    }
}

final class CodeEditorView: UIView {
    let appearance: Appearance
    weak var delegate: CodeEditorViewDelegate?

    private lazy var codeTextView: CodeTextView = {
        let codeTextView = CodeTextView()
        codeTextView.delegate = self

        codeTextView.autocapitalizationType = .none
        codeTextView.autocorrectionType = .no
        codeTextView.spellCheckingType = .no
        codeTextView.smartDashesType = .no
        codeTextView.smartQuotesType = .no
        codeTextView.smartInsertDeleteType = .no

        if #available(iOS 13.0, *) {
            codeTextView.automaticallyAdjustsScrollIndicatorInsets = false
        }

        return codeTextView
    }()

    private lazy var languageNameLabel: UILabel = {
        let label = PaddingLabel(padding: self.appearance.languageNameLabelInsets)
        label.textAlignment = .center

        label.clipsToBounds = true
        label.layer.cornerRadius = self.appearance.languageNameLabelCornerRadius

        label.textColor = self.appearance.languageNameLabelTextColor
        label.backgroundColor = self.appearance.languageNameLabelBackgroundColor
        label.font = self.appearance.languageNameLabelFont

        return label
    }()

    private var languageNameLabelTopConstraint: Constraint?

    private let codePlaygroundManager = CodePlaygroundManager()
    // Uses by codePlaygroundManager for analysis between current code and old one (suggestions & completions).
    private var oldCode: String?

    private let elementsSize: CodeQuizElementsSize = DeviceInfo.current.isPad ? .big : .small
    private var tabSize = 0

    var code: String? {
        get {
            self.codeTextView.text
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
            self.languageNameLabel.text = self.language?.rawValue
            self.setupAccessoryView(isEditable: self.isEditable)
        }
    }

    var theme: CodeEditorTheme? {
        didSet {
            if let theme = self.theme {
                self.codeTextView.updateTheme(name: theme.name, font: theme.font)
            }
        }
    }

    var isThemeAutoUpdatable = true

    var shouldHighlightCurrentLine = true {
        didSet {
            self.codeTextView.shouldHighlightCurrentLine = self.shouldHighlightCurrentLine
        }
    }

    var isEditable = true {
        didSet {
            self.setupAccessoryView(isEditable: self.isEditable)
        }
    }

    var isLanguageNameVisible = false {
        didSet {
            self.languageNameLabel.isHidden = !self.isLanguageNameVisible
            self.languageNameLabel.alpha = self.isLanguageNameVisible ? 1 : 0
        }
    }

    var textInsets: UIEdgeInsets = .zero {
        didSet {
            self.codeTextView.textContainerInset = self.textInsets
        }
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

        self.updateThemeIfAutoUpdatable()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.themeDidChange),
            name: .codeEditorThemeDidChange,
            object: nil
        )
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.languageNameLabelTopConstraint?.update(
            offset: max(0, self.codeTextView.contentInset.top) + self.appearance.languageNameLabelLayoutInsets.top
        )
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

    @objc
    private func themeDidChange() {
        self.updateThemeIfAutoUpdatable()
    }

    private func updateThemeIfAutoUpdatable() {
        if self.isThemeAutoUpdatable {
            self.theme = CodeEditorThemeService().theme
        }
    }
}

extension CodeEditorView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.isLanguageNameVisible = false
    }

    func addSubviews() {
        self.addSubview(self.codeTextView)
        self.addSubview(self.languageNameLabel)
    }

    func makeConstraints() {
        self.codeTextView.translatesAutoresizingMaskIntoConstraints = false
        self.codeTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.languageNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.languageNameLabel.snp.makeConstraints { make in
            self.languageNameLabelTopConstraint = make.top.equalTo(self.safeAreaLayoutGuide).constraint
            make.trailing.equalToSuperview().offset(-self.appearance.languageNameLabelLayoutInsets.right)
        }
    }
}

// MARK: - CodeEditorView: UITextViewDelegate -

extension CodeEditorView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.delegate?.codeEditorView(self, beginEditing: self.isEditable)
        return self.isEditable
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.codeEditorViewDidBeginEditing(self)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.codeEditorViewDidEndEditing(self)
    }

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

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        false
    }

    func textView(
        _ textView: UITextView,
        shouldInteractWith textAttachment: NSTextAttachment,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        false
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool { false }

    func textView(
        _ textView: UITextView,
        shouldInteractWith textAttachment: NSTextAttachment,
        in characterRange: NSRange
    ) -> Bool {
        false
    }
}

// MARK: - CodeEditorView: CodeSuggestionDelegate -

extension CodeEditorView: CodeSuggestionDelegate {
    var suggestionsSize: CodeSuggestionsSize { self.elementsSize.elements.suggestions }

    func didSelectSuggestion(suggestion: String, prefix: String) {
        guard self.codeTextView.isEditable else {
            return
        }

        self.codeTextView.becomeFirstResponder()

        let symbols = String(suggestion[suggestion.index(suggestion.startIndex, offsetBy: prefix.count)...])
        self.codePlaygroundManager.insertAtCurrentPosition(symbols: symbols, textView: self.codeTextView)

        self.analyzeCodeAndComplete()
    }
}
