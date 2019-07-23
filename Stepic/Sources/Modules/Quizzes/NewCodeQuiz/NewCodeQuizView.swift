import SnapKit
import UIKit

extension NewCodeQuizView {
    struct Appearance { }
}

final class NewCodeQuizView: UIView {
    let appearance: Appearance

    private lazy var detailsView: CodeDetailsView = {
        let codeDetailsView = CodeDetailsView()
        return codeDetailsView
    }()

    private lazy var languagePickerView: CodeLanguagePickerView = {
        let languagePickerView = CodeLanguagePickerView()
        return languagePickerView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.detailsView, self.languagePickerView])
        stackView.axis = .vertical
        return stackView
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
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
        self.detailsView.configure(viewModel: .init(samples: viewModel.samples, limit: viewModel.limit))
    }
}

extension NewCodeQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() { }

    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
