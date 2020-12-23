import SnapKit
import UIKit

protocol CodeQuizViewDelegate: AnyObject {
    func codeQuizView(_ view: CodeQuizView, didSelectLanguage language: CodeLanguage)
    func codeQuizView(_ view: CodeQuizView, didUpdateCode code: String)
    func codeQuizViewDidRequestFullscreen(_ view: CodeQuizView)
    func codeQuizViewDidRequestPresentationController(_ view: CodeQuizView) -> UIViewController?
}

extension CodeQuizView {
    struct Appearance {
        let titleColor = UIColor.stepikPrimaryText
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)

        let insets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)

        let codeTextViewHeight: CGFloat = 236
    }
}

final class CodeQuizView: UIView, TitlePresentable {
    let appearance: Appearance
    weak var delegate: CodeQuizViewDelegate?

    // Only visible for sql quiz.
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleColor
        label.font = self.appearance.titleFont
        return label
    }()

    private lazy var codeDetailsView = CodeDetailsView()

    private lazy var languagePickerView: CodeLanguagePickerView = {
        let languagePickerView = CodeLanguagePickerView()
        languagePickerView.delegate = self
        return languagePickerView
    }()

    private lazy var toolbarView: CodeToolbarView = {
        let toolbarView = CodeToolbarView()
        toolbarView.onPickLanguageButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if strongSelf.languagePickerView.languages.isEmpty {
                strongSelf.toolbarView.toggleLanguagePickerButton()
            } else {
                strongSelf.languagePickerView.isHidden.toggle()
                strongSelf.codeEditorStackView.isHidden = !strongSelf.languagePickerView.isHidden
            }
        }
        toolbarView.onFullscreenButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.codeQuizViewDidRequestFullscreen(strongSelf)
        }
        return toolbarView
    }()

    private lazy var codeEditorView: CodeEditorView = {
        let codeEditorView = CodeEditorView()
        codeEditorView.isThemeAutoUpdatable = true
        codeEditorView.shouldHighlightCurrentLine = false
        codeEditorView.delegate = self
        return codeEditorView
    }()

    private lazy var codeEditorStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [SeparatorView(), self.codeEditorView, SeparatorView()])
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var unsupportedCodeLanguageStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [SeparatorView(), UnsupportedCodeLanguageView(), SeparatorView()])
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.codeDetailsView,
                self.toolbarView,
                self.titleLabelContainerView,
                self.codeEditorStackView,
                self.languagePickerView,
                self.unsupportedCodeLanguageStackView
            ]
        )
        stackView.axis = .vertical
        return stackView
    }()

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

    // TODO: Refactor rendering and state management.
    func configure(viewModel: CodeQuizViewModel) {
        switch viewModel.finalState {
        case .default, .wrong:
            self.setCodeEditorReady(true)
            self.setCodeEditorActionControlsEnabled(true)
            self.toolbarView.isLanguagePickerEnabled = viewModel.languages.count > 1
        case .correct, .evaluation:
            self.setCodeEditorReady(true)
            self.setCodeEditorActionControlsEnabled(false)
        case .noLanguage:
            self.setCodeEditorReady(false)
            self.setCodeEditorActionControlsEnabled(false)
        case .unsupportedLanguage:
            self.languagePickerView.isHidden = true
            self.toolbarView.isHidden = true
            self.codeEditorStackView.isHidden = true
            self.unsupportedCodeLanguageStackView.isHidden = false
            self.setCodeEditorActionControlsEnabled(false)
        }

        let isEmptyDetails = viewModel.samples.isEmpty && viewModel.limit.memory == 0 && viewModel.limit.time == 0
        self.codeDetailsView.isHidden = isEmptyDetails
        self.codeDetailsView.configure(samples: viewModel.samples, limit: viewModel.limit)

        self.languagePickerView.languages = viewModel.languages.map { $0.rawValue }.sorted()

        self.toolbarView.language = viewModel.language?.rawValue
        self.toolbarView.isTopSeparatorHidden = !isEmptyDetails
        self.toolbarView.isBottomSeparatorHidden = true

        self.codeEditorView.language = viewModel.language
        self.codeEditorView.code = viewModel.code
        self.codeEditorView.codeTemplate = viewModel.codeTemplate
        self.codeEditorView.theme = viewModel.codeEditorTheme
        self.codeEditorView.isEditable = false

        // Hide toolbar and show title for sql quiz.
        if viewModel.language == .sql {
            self.title = viewModel.title
            self.toolbarView.isHidden = !self.titleLabelContainerView.isHidden
        } else {
            self.titleLabelContainerView.isHidden = true
        }
    }

    func setCodeEditorActionControlsEnabled(_ isEnabled: Bool) {
        self.toolbarView.isEnabled = isEnabled
        self.codeEditorView.isEditable = isEnabled
    }

    // MARK: Private API

    private func setCodeEditorReady(_ isReady: Bool) {
        self.languagePickerView.isHidden = isReady
        self.toolbarView.isHidden = !isReady
        self.codeEditorStackView.isHidden = !isReady
        self.unsupportedCodeLanguageStackView.isHidden = true
    }
}

extension CodeQuizView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.titleLabelContainerView.addSubview(self.titleLabel)
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.codeEditorView.translatesAutoresizingMaskIntoConstraints = false
        self.codeEditorView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.codeTextViewHeight)
        }
    }
}

extension CodeQuizView: CodeLanguagePickerViewDelegate {
    func codeLanguagePickerView(_ view: CodeLanguagePickerView, didSelectLanguage language: String) {
        if let codeLanguage = CodeLanguage(rawValue: language) {
            self.delegate?.codeQuizView(self, didSelectLanguage: codeLanguage)
        }

        self.toolbarView.collapseLanguagePickerButton()
    }
}

extension CodeQuizView: CodeEditorViewDelegate {
    func codeEditorViewDidChange(_ codeEditorView: CodeEditorView) {
        self.delegate?.codeQuizView(self, didUpdateCode: codeEditorView.code ?? "")
    }

    func codeEditorViewDidRequestSuggestionPresentationController(
        _ codeEditorView: CodeEditorView
    ) -> UIViewController? {
        self.delegate?.codeQuizViewDidRequestPresentationController(self)
    }

    func codeEditorView(_ codeEditorView: CodeEditorView, beginEditing editing: Bool) {
        if self.toolbarView.isEnabled {
            self.delegate?.codeQuizViewDidRequestFullscreen(self)
        }
    }
}
