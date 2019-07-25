import SnapKit
import UIKit

protocol CodeEditorViewDelegate: class {
    func codeEditorViewDidChange(_ codeEditorView: CodeEditorView)
}

extension CodeEditorView {
    struct Appearance {
    }
}

final class CodeEditorView: UIView {
    let appearance: Appearance
    weak var delegate: CodeEditorViewDelegate?

    private lazy var codeTextView: CodeTextView = {
        let codeTextView = CodeTextView()
        codeTextView.delegate = self
        return codeTextView
    }()

    var code: String? {
        get {
            return self.codeTextView.text
        }
        set {
            self.codeTextView.text = newValue
        }
    }

    var language: CodeLanguage? {
        didSet {
            self.codeTextView.language = self.language?.highlightr
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
