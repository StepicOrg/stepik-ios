import SnapKit
import UIKit

extension CodeDetailsView {
    struct Appearance {
        let spacing: CGFloat = 1
        let backgroundColor = UIColor.white

        let detailsButtonHeight: CGFloat = 44
    }

    enum Animation {
        static let appearanceAnimationDuration: TimeInterval = 0.33
    }
}

// TODO: Respect safe area layout gide
final class CodeDetailsView: UIView {
    let appearance: Appearance

    private lazy var detailsButton: CodeDetailsButton = {
        let detailsButton = CodeDetailsButton()
        detailsButton.title = NSLocalizedString("CodeQuizDetails", comment: "")
        detailsButton.addTarget(self, action: #selector(self.detailsButtonClicked), for: .touchUpInside)
        return detailsButton
    }()

    private lazy var detailsContentView = CodeDetailsContentView()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.detailsButton, self.detailsContentView])
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private var isDetailsHidden = true {
        didSet {
            self.detailsContentView.isHidden = self.isDetailsHidden
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

    func configure(viewModel: NewCodeQuizCodeDetailsViewModel) {
        self.detailsContentView.configure(samples: viewModel.samples, limit: viewModel.limit)
    }

    @objc
    private func detailsButtonClicked() {
        UIView.animate(withDuration: Animation.appearanceAnimationDuration) {
            self.isDetailsHidden.toggle()
        }
    }
}

extension CodeDetailsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.isDetailsHidden = true
    }

    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.detailsButton.translatesAutoresizingMaskIntoConstraints = false
        self.detailsButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.detailsButtonHeight)
        }
    }
}
