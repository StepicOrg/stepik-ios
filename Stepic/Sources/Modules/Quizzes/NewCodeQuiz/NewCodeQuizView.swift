import SnapKit
import UIKit

protocol NewCodeQuizViewDelegate: AnyObject {
    func newCodeQuizView(_ view: NewCodeQuizView, didSelectLanguage language: CodeLanguage)
    func newCodeQuizView(_ view: NewCodeQuizView, didUpdateCode code: String)
    func newCodeQuizViewDidRequestFullscreen(_ view: NewCodeQuizView)
    // TODO: Remove this after CodePlaygroundManager code suggestion presentation refactoring.
    func newCodeQuizViewDidRequestPresentationController(_ view: NewCodeQuizView) -> UIViewController?
}

extension NewCodeQuizView {
    struct Appearance {
        let titleColor = UIColor.mainDark
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)

        let insets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)

        let codeTextViewHeight: CGFloat = 236
    }
}

final class NewCodeQuizView: UIView {
    let appearance: Appearance
    weak var delegate: NewCodeQuizViewDelegate?

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

            strongSelf.delegate?.newCodeQuizViewDidRequestFullscreen(strongSelf)
        }
        return toolbarView
    }()

    private lazy var codeEditorView: CodeEditorView = {
        let codeEditorView = CodeEditorView()
        codeEditorView.delegate = self
        codeEditorView.isThemeAutoUpdating = true
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
                self.topSeparatorContainerView,
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

    private lazy var topSeparatorContainerView = UIView()
    private lazy var titleLabelContainerView = UIView()

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
    func configure(viewModel: NewCodeQuizViewModel) {
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
            self.titleLabel.text = viewModel.title
            self.titleLabelContainerView.isHidden = viewModel.title?.isEmpty ?? true
            self.toolbarView.isHidden = !self.titleLabelContainerView.isHidden
        } else {
            self.titleLabelContainerView.isHidden = true
        }
    }

    // MARK: - Private API

    private func setCodeEditorReady(_ isReady: Bool) {
        self.languagePickerView.isHidden = isReady
        self.toolbarView.isHidden = !isReady
        self.codeEditorStackView.isHidden = !isReady
        self.unsupportedCodeLanguageStackView.isHidden = true
    }

    private func setCodeEditorActionControlsEnabled(_ isEnabled: Bool) {
        self.toolbarView.isEnabled = isEnabled
        self.codeEditorView.isEditable = isEnabled
    }
}

extension NewCodeQuizView: ProgrammaticallyInitializableViewProtocol {
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

extension NewCodeQuizView: CodeLanguagePickerViewDelegate {
    func codeLanguagePickerView(_ view: CodeLanguagePickerView, didSelectLanguage language: String) {
        if let codeLanguage = CodeLanguage(rawValue: language) {
            self.delegate?.newCodeQuizView(self, didSelectLanguage: codeLanguage)
        }

        self.toolbarView.collapseLanguagePickerButton()
    }
}

extension NewCodeQuizView: CodeEditorViewDelegate {
    func codeEditorViewDidChange(_ codeEditorView: CodeEditorView) {
        self.delegate?.newCodeQuizView(self, didUpdateCode: codeEditorView.code ?? "")
    }

    func codeEditorViewDidRequestSuggestionPresentationController(
        _ codeEditorView: CodeEditorView
    ) -> UIViewController? {
        return self.delegate?.newCodeQuizViewDidRequestPresentationController(self)
    }

    func codeEditorView(_ codeEditorView: CodeEditorView, beginEditing editing: Bool) {
        if self.toolbarView.isEnabled {
            self.delegate?.newCodeQuizViewDidRequestFullscreen(self)
        }
    }
}
