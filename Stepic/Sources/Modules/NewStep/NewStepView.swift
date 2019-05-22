import SnapKit
import UIKit

extension NewStepView {
    struct Appearance { }
}

final class NewStepView: UIView {
    let appearance: Appearance

    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView(orientation: .vertical)
        return view
    }()

    private lazy var stepTextView: ProcessedContentTextView = {
        let view = ProcessedContentTextView()
        return view
    }()

    private lazy var stepControlsView: StepControlsView = {
        let view = StepControlsView(navigationState: .both)
        return view
    }()

    private lazy var quizContainerView = UIView()

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

    func configure(viewModel: NewStepViewModel, quizView: UIView?) {
        self.stepTextView.loadHTMLText(viewModel.htmlString)

        guard let quizView = quizView else {
            return
        }

        self.quizContainerView.addSubview(quizView)
        quizView.translatesAutoresizingMaskIntoConstraints = false
        quizView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension NewStepView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.scrollableStackView.addArrangedView(self.stepTextView)
        self.scrollableStackView.addArrangedView(self.quizContainerView)
        self.scrollableStackView.addArrangedView(self.stepControlsView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
