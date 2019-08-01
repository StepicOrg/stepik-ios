import SnapKit
import UIKit

protocol NewCodeQuizFullscreenInstructionViewDelegate: class {
    func newCodeQuizFullscreenInstructionViewDidLoadContent(_ view: NewCodeQuizFullscreenInstructionView)
    func newCodeQuizFullscreenInstructionView(_ view: NewCodeQuizFullscreenInstructionView, didRequestOpenURL url: URL)
    func newCodeQuizFullscreenInstructionView(
        _ view: NewCodeQuizFullscreenInstructionView,
        didRequestFullscreenImage url: URL
    )
}

extension NewCodeQuizFullscreenInstructionView {
    struct Appearance {
        let loadingIndicatorColor = UIColor.mainDark
        let spacing: CGFloat = 16
    }

    enum Animation {
        static let appearanceAnimationDuration: TimeInterval = 0.25
        static let appearanceAnimationDelay: TimeInterval = 0.3
    }
}

final class NewCodeQuizFullscreenInstructionView: UIView {
    let appearance: Appearance
    weak var delegate: NewCodeQuizFullscreenInstructionViewDelegate?

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicatorView.color = self.appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView(orientation: .vertical)
        view.spacing = self.appearance.spacing
        return view
    }()

    private lazy var stepTextView: ProcessedContentTextView = {
        let view = ProcessedContentTextView()
        view.delegate = self
        return view
    }()

    private lazy var detailsContentView: CodeDetailsContentView = {
        let view = CodeDetailsContentView()
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

    // MARK: Public API

    func startLoading() {
        self.scrollableStackView.alpha = 0.0
        self.loadingIndicatorView.startAnimating()
    }

    func endLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Animation.appearanceAnimationDelay) {
            self.loadingIndicatorView.stopAnimating()

            UIView.animate(
                withDuration: Animation.appearanceAnimationDuration,
                animations: {
                    self.scrollableStackView.alpha = 1.0
                }
            )
        }
    }

    func configure(htmlString: String, samples: [NewCodeQuiz.CodeSample], limit: NewCodeQuiz.CodeLimit) {
        self.scrollableStackView.insertArrangedView(self.stepTextView, at: 0)
        self.stepTextView.loadHTMLText(htmlString)

        self.detailsContentView.configure(samples: samples, limit: limit)
    }
}

extension NewCodeQuizFullscreenInstructionView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.scrollableStackView.addArrangedView(self.detailsContentView)

        self.addSubview(self.loadingIndicatorView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension NewCodeQuizFullscreenInstructionView: ProcessedContentTextViewDelegate {
    func processedContentTextView(_ view: ProcessedContentTextView, didOpenLink url: URL) {
        self.delegate?.newCodeQuizFullscreenInstructionView(self, didRequestOpenURL: url)
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenImage url: URL) {
        self.delegate?.newCodeQuizFullscreenInstructionView(self, didRequestFullscreenImage: url)
    }

    func processedContentTextViewDidLoadContent(_ view: ProcessedContentTextView) {
        self.delegate?.newCodeQuizFullscreenInstructionViewDidLoadContent(self)
    }
}
