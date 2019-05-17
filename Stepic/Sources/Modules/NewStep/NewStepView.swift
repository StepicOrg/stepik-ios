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

    func configure(viewModel: NewStepViewModel) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let contentProcessor = ContentProcessor(
                content: viewModel.text,
                rules: [],
                injections: [CommonStylesInjection()]
            )
            let content = contentProcessor.processContent()

            DispatchQueue.main.async { [weak self] in
                self?.stepTextView.loadHTMLText(content)
            }
        }
    }
}

extension NewStepView: ProgrammaticallyInitializableViewProtocol {
    func setupView() { }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.scrollableStackView.addArrangedView(self.stepTextView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Test
        let stubView1 = UIView()
        stubView1.backgroundColor = UIColor.lightBlue.withAlphaComponent(0.2)
        self.scrollableStackView.addArrangedView(stubView1)
        stubView1.snp.makeConstraints { make in
            make.height.equalTo(600)
        }
    }
}
