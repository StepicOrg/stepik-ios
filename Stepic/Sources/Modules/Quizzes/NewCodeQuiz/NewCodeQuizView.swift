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
        self.addSubview(self.detailsView)
    }

    func makeConstraints() {
        self.detailsView.translatesAutoresizingMaskIntoConstraints = false
        self.detailsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
