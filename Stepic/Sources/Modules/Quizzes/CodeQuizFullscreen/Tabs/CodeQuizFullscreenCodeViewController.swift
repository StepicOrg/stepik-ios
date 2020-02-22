import SnapKit
import UIKit

protocol CodeQuizFullscreenCodeViewControllerDelegate: AnyObject {
    func codeQuizFullscreenCodeViewController(
        _ viewController: CodeQuizFullscreenCodeViewController,
        codeDidChange code: String
    )
    func codeQuizFullscreenCodeViewController(
        _ viewController: CodeQuizFullscreenCodeViewController,
        didSubmitCode code: String
    )
    func codeQuizFullscreenCodeViewController(
        _ viewController: CodeQuizFullscreenCodeViewController,
        didEndEditingCode code: String
    )
}

extension CodeQuizFullscreenCodeViewController {
    enum Appearance {
        static let submitButtonBackgroundColor = UIColor.stepikGreen
        static let submitButtonHeight: CGFloat = 44
        static let submitButtonTextColor = UIColor.white
        static let submitButtonCornerRadius: CGFloat = 6
        static let submitButtonFont = UIFont.systemFont(ofSize: 16)
        static let submitButtonInsets = UIEdgeInsets(top: 0, left: 32, bottom: 16, right: 32)

        static let codeEditorTextTopInset: CGFloat = 8

        static let languageNameLabelLayoutInsets = LayoutInsets(top: 8, right: 8)
    }
}

final class CodeQuizFullscreenCodeViewController: UIViewController {
    weak var delegate: CodeQuizFullscreenCodeViewControllerDelegate?

    private lazy var codeEditorView: CodeEditorView = {
        let appearance = CodeEditorView.Appearance(
            languageNameLabelLayoutInsets: Appearance.languageNameLabelLayoutInsets
        )
        let codeEditorView = CodeEditorView(appearance: appearance)
        codeEditorView.isThemeAutoUpdatable = true
        codeEditorView.shouldHighlightCurrentLine = false
        codeEditorView.delegate = self
        return codeEditorView
    }()

    private lazy var submitButton: UIButton = {
        let submitButton = UIButton(type: .system)
        submitButton.setTitleColor(Appearance.submitButtonTextColor, for: .normal)
        submitButton.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)
        submitButton.titleLabel?.font = Appearance.submitButtonFont
        submitButton.layer.cornerRadius = Appearance.submitButtonCornerRadius
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = Appearance.submitButtonBackgroundColor
        submitButton.addTarget(self, action: #selector(self.submitClicked), for: .touchUpInside)
        return submitButton
    }()

    private var isSubmitButtonEnabled = true {
        didSet {
            self.submitButton.isEnabled = self.isSubmitButtonEnabled
            self.submitButton.alpha = self.isSubmitButtonEnabled ? 1.0 : 0.5
        }
    }

    private var isSubmitButtonHidden = false {
        didSet {
            self.submitButton.isHidden = self.isSubmitButtonHidden
            let bottomInset = self.isSubmitButtonHidden
                ? 0.0
                : Appearance.submitButtonHeight + Appearance.submitButtonInsets.bottom
            self.codeEditorView.textInsets = UIEdgeInsets(
                top: Appearance.codeEditorTextTopInset,
                left: 0,
                bottom: bottomInset,
                right: 0
            )
        }
    }

    private var language: CodeLanguage
    private var codeTemplate: String?

    var code: String? {
        didSet {
            self.codeEditorView.code = self.code
        }
    }

    init(
        language: CodeLanguage,
        code: String?,
        codeTemplate: String?,
        delegate: CodeQuizFullscreenCodeViewControllerDelegate? = nil
    ) {
        self.language = language
        self.code = code
        self.codeTemplate = codeTemplate
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSubviews()
        self.setupCodeEditor()
    }

    // MARK: Private API

    private func addSubviews() {
        self.view.addSubview(self.codeEditorView)
        self.codeEditorView.translatesAutoresizingMaskIntoConstraints = false
        self.codeEditorView.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }

        self.view.addSubview(self.submitButton)
        self.submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.submitButton.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(Appearance.submitButtonInsets)
            make.height.equalTo(Appearance.submitButtonHeight)
        }
    }

    private func setupCodeEditor() {
        self.codeEditorView.language = self.language
        self.codeEditorView.isLanguageNameVisible = true
        self.codeEditorView.codeTemplate = self.codeTemplate
        self.codeEditorView.code = self.code
    }

    @objc
    private func submitClicked() {
        self.delegate?.codeQuizFullscreenCodeViewController(self, didSubmitCode: self.codeEditorView.code ?? "")
    }
}

// MARK: - CodeQuizFullscreenCodeViewController: CodeEditorViewDelegate -

extension CodeQuizFullscreenCodeViewController: CodeEditorViewDelegate {
    func codeEditorViewDidChange(_ codeEditorView: CodeEditorView) {
        let currentCode = (codeEditorView.code ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.isSubmitButtonEnabled = !currentCode.isEmpty

        self.delegate?.codeQuizFullscreenCodeViewController(self, codeDidChange: codeEditorView.code ?? "")
    }

    func codeEditorViewDidBeginEditing(_ codeEditorView: CodeEditorView) {
        self.isSubmitButtonHidden = true
        self.codeEditorView.shouldHighlightCurrentLine = true
    }

    func codeEditorViewDidEndEditing(_ codeEditorView: CodeEditorView) {
        self.isSubmitButtonHidden = false
        self.codeEditorView.shouldHighlightCurrentLine = false

        self.delegate?.codeQuizFullscreenCodeViewController(self, didEndEditingCode: codeEditorView.code ?? "")
    }

    func codeEditorViewDidRequestSuggestionPresentationController(
        _ codeEditorView: CodeEditorView
    ) -> UIViewController? {
        self
    }
}
