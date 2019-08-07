import SnapKit
import UIKit

protocol NewCodeQuizFullscreenCodeViewControllerDelegate: class {
    func newCodeQuizFullscreenCodeViewController(
        _ viewController: NewCodeQuizFullscreenCodeViewController,
        codeDidChange code: String
    )

    func newCodeQuizFullscreenCodeViewController(
        _ viewController: NewCodeQuizFullscreenCodeViewController,
        didSubmitCode code: String
    )
}

final class NewCodeQuizFullscreenCodeViewController: UIViewController {
    enum Appearance {
        static let submitButtonBackgroundColor = UIColor.stepicGreen
        static let submitButtonHeight: CGFloat = 44
        static let submitButtonTextColor = UIColor.white
        static let submitButtonCornerRadius: CGFloat = 6
        static let submitButtonFont = UIFont.systemFont(ofSize: 16)
        static let submitButtonInsets = LayoutInsets(left: 32, bottom: 16, right: 32)

        static let codeEditorTextTopInset: CGFloat = 8
    }

    weak var delegate: NewCodeQuizFullscreenCodeViewControllerDelegate?

    private lazy var codeEditorView: CodeEditorView = {
        let codeEditorView = CodeEditorView()
        codeEditorView.isThemeAutoUpdating = true
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

    private var language: CodeLanguage? {
        didSet {
            self.codeEditorView.language = self.language
            self.codeEditorView.isLanguageNameVisible = self.language != nil
        }
    }

    private var code: String? {
        didSet {
            self.codeEditorView.code = self.code
        }
    }

    private var codeTemplate: String? {
        didSet {
            self.codeEditorView.codeTemplate = self.codeTemplate
        }
    }

    init(delegate: NewCodeQuizFullscreenCodeViewControllerDelegate? = nil) {
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
        self.isSubmitButtonHidden = false
    }

    // MARK: - Private API

    private func addSubviews() {
        self.view.addSubview(self.codeEditorView)
        self.codeEditorView.translatesAutoresizingMaskIntoConstraints = false
        self.codeEditorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.view.addSubview(self.submitButton)
        self.submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.submitButton.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.bottom
                    .equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                    .offset(-Appearance.submitButtonInsets.bottom)
            } else {
                make.bottom.equalToSuperview().offset(-Appearance.submitButtonInsets.bottom)
            }
            make.leading.equalToSuperview().offset(Appearance.submitButtonInsets.left)
            make.trailing.equalToSuperview().offset(-Appearance.submitButtonInsets.right)
            make.height.equalTo(Appearance.submitButtonHeight)
        }
    }

    @objc
    private func submitClicked() {
        self.delegate?.newCodeQuizFullscreenCodeViewController(self, didSubmitCode: self.codeEditorView.code ?? "")
    }
}

extension NewCodeQuizFullscreenCodeViewController: NewCodeQuizFullscreenSubmoduleProtocol {
    func configure(viewModel: NewCodeQuizFullscreenViewModel) {
        self.language = viewModel.language
        self.code = viewModel.code
        self.codeTemplate = viewModel.codeTemplate
    }
}

extension NewCodeQuizFullscreenCodeViewController: CodeEditorViewDelegate {
    func codeEditorViewDidChange(_ codeEditorView: CodeEditorView) {
        let currentCode = (codeEditorView.code ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.isSubmitButtonEnabled = !currentCode.isEmpty

        self.delegate?.newCodeQuizFullscreenCodeViewController(self, codeDidChange: codeEditorView.code ?? "")
    }

    func codeEditorViewDidBeginEditing(_ codeEditorView: CodeEditorView) {
        self.isSubmitButtonHidden = true
    }

    func codeEditorViewDidEndEditing(_ codeEditorView: CodeEditorView) {
        self.isSubmitButtonHidden = false
    }

    func codeEditorViewDidRequestSuggestionPresentationController(
        _ codeEditorView: CodeEditorView
    ) -> UIViewController? {
        return self
    }
}
