import SnapKit
import UIKit

protocol NewCodeQuizViewDelegate: class {
    func newCodeQuizView(_ view: NewCodeQuizView, didSelectLanguage language: CodeLanguage)
    func newCodeQuizViewDidRequestFullscreen(_ view: NewCodeQuizView)
    func newCodeQuizView(_ view: NewCodeQuizView, didUpdateCode code: String)
}

extension NewCodeQuizView {
    struct Appearance {
        let codeTextViewHeight: CGFloat = 236
    }
}

final class NewCodeQuizView: UIView {
    let appearance: Appearance
    weak var delegate: NewCodeQuizViewDelegate?

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
        return codeEditorView
    }()

    private lazy var codeEditorStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [SeparatorView(), self.codeEditorView, SeparatorView()])
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.codeDetailsView,
                self.toolbarView,
                self.codeEditorStackView,
                self.languagePickerView
            ]
        )
        stackView.axis = .vertical
        return stackView
    }()

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

    func configure(viewModel: NewCodeQuizViewModel) {
        switch viewModel.finalState {
        case .default:
            self.languagePickerView.isHidden = true
            self.toolbarView.isHidden = false
            self.codeEditorStackView.isHidden = false
            self.setActionControlsEnabled(true)
        case .correct:
            self.languagePickerView.isHidden = true
            self.toolbarView.isHidden = false
            self.codeEditorStackView.isHidden = false
            self.setActionControlsEnabled(false)
        case .wrong:
            self.languagePickerView.isHidden = true
            self.toolbarView.isHidden = false
            self.codeEditorStackView.isHidden = false
            self.setActionControlsEnabled(false)
        case .evaluation:
            self.languagePickerView.isHidden = true
            self.toolbarView.isHidden = false
            self.codeEditorStackView.isHidden = false
            self.setActionControlsEnabled(false)
        case .noLanguage:
            self.languagePickerView.isHidden = false
            self.toolbarView.isHidden = true
            self.codeEditorStackView.isHidden = true
            self.setActionControlsEnabled(false)
        case .unsupportedLanguage:
            self.languagePickerView.isHidden = true
            self.toolbarView.isHidden = true
            self.codeEditorStackView.isHidden = true
            self.setActionControlsEnabled(false)
        }

        self.codeDetailsView.configure(samples: viewModel.samples, limit: viewModel.limit)
        self.languagePickerView.languages = viewModel.languages.map { $0.rawValue }.sorted()

        self.toolbarView.language = viewModel.language?.rawValue
        self.toolbarView.isLanguagePickerEnabled = viewModel.languages.count > 1

        self.codeEditorView.language = viewModel.language
        self.codeEditorView.code = viewModel.code
        self.codeEditorView.theme = .init(name: viewModel.codeEditorTheme.name, font: viewModel.codeEditorTheme.font)
    }

    // MARK: - Private API

    private func setActionControlsEnabled(_ enabled: Bool) {
        self.toolbarView.isEnabled = enabled
        self.codeEditorView.isEnabled = enabled
    }
}

extension NewCodeQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
    }

    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
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
        guard let codeLanguage = CodeLanguage(rawValue: language) else {
            return
        }

        self.delegate?.newCodeQuizView(self, didSelectLanguage: codeLanguage)
        self.toolbarView.collapseLanguagePickerButton()
    }
}

extension NewCodeQuizView: CodeEditorViewDelegate {
    func codeEditorViewDidChange(_ codeEditorView: CodeEditorView) {
        self.delegate?.newCodeQuizView(self, didUpdateCode: codeEditorView.code ?? "")
    }
}
