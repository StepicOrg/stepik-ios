import SnapKit
import UIKit

extension ChoiceElementView {
    struct Appearance {
        let contentInsets = LayoutInsets(top: 12, left: 16, bottom: 12, right: 16)

        let shadowColor = UIColor(hex: 0xEAECF0)
        let shadowOffset = CGSize(width: 0, height: 1)
        let shadowRadius: CGFloat = 4

        let feedbackBackgroundColor = UIColor(hex: 0xF6F6F6)
        let feedbackContentInsets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

final class ChoiceElementView: UIView {
    let appearance: Appearance

    private lazy var quizElementView = QuizElementView()
    private lazy var contentView: ProcessedContentTextView = {
        var appearance = ProcessedContentTextView.Appearance(
            insets: LayoutInsets(insets: .zero),
            backgroundColor: .clear
        )
        let view = ProcessedContentTextView(appearance: appearance)
        view.isScrollEnabled = true
        view.delegate = self
        return view
    }()

    private lazy var shadowView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        view.backgroundColor = .clear
        view.layer.shadowColor = self.appearance.shadowColor.cgColor
        view.layer.shadowOffset = self.appearance.shadowOffset
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = self.appearance.shadowRadius
        return view
    }()

    private lazy var feedbackView: ProcessedContentTextView = {
        var appearance = ProcessedContentTextView.Appearance()
        appearance.insets = LayoutInsets(insets: .zero)
        appearance.backgroundColor = .clear

        let view = ProcessedContentTextView(appearance: appearance)
        return view
    }()

    private lazy var feedbackContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = self.appearance.feedbackBackgroundColor
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.quizElementView, self.feedbackContainerView])
        stackView.axis = .vertical
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        let feedbackHeight = self.feedbackView.intrinsicContentSize.height
            + self.appearance.feedbackContentInsets.top
            + self.appearance.feedbackContentInsets.bottom
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.contentView.intrinsicContentSize.height
                + self.appearance.contentInsets.top
                + self.appearance.contentInsets.bottom
                + (self.hint != nil ? feedbackHeight : 0)
        )
    }

    var text: String? {
        didSet {
            self.contentView.loadHTMLText(self.text ?? "")
        }
    }

    var state = State.default {
        didSet {
            self.updateState()
        }
    }

    var isEnabled = true {
        didSet {
            self.updateState()
        }
    }

    var hint: String? {
        didSet {
            self.feedbackView.isHidden = false
            self.feedbackContainerView.isHidden = self.hint == nil
            self.quizElementView.useCornersOnlyOnTop = self.hint != nil

            self.feedbackView.loadHTMLText(self.hint ?? "")
        }
    }

    var onContentLoad: (() -> Void)?

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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()

        DispatchQueue.main.async {
            self.shadowView.layer.shadowPath = UIBezierPath(
                roundedRect: self.shadowView.bounds,
                cornerRadius: self.quizElementView.appearance.cornerRadius
            ).cgPath
            self.updateCornersForFeedback()
        }
    }

    // MARK: - Private API

    private func updateCornersForFeedback() {
        let path = UIBezierPath(
            roundedRect: self.feedbackContainerView.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(
                width: self.quizElementView.appearance.cornerRadius,
                height: self.quizElementView.appearance.cornerRadius
            )
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.feedbackContainerView.layer.mask = mask
    }

    private func updateState() {
        switch self.state {
        case .default:
            self.quizElementView.state = .default
        case .correct:
            self.quizElementView.state = .correct
        case .wrong:
            self.quizElementView.state = .wrong
        case .selected:
            self.quizElementView.state = .selected
        }

        self.shadowView.isHidden = !self.isEnabled
    }

    // MARK: - Enums

    enum State {
        case `default`
        case correct
        case wrong
        case selected
    }
}

extension ChoiceElementView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.clipsToBounds = false
        self.updateState()
    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.feedbackContainerView.addSubview(self.feedbackView)
        self.quizElementView.addSubview(self.contentView)

        self.insertSubview(self.shadowView, belowSubview: self.stackView)
    }

    func makeConstraints() {
        self.shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowView.snp.makeConstraints { make in
            make.center.equalTo(self.quizElementView)
            make.size.equalTo(self.quizElementView)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.feedbackView.translatesAutoresizingMaskIntoConstraints = false
        self.feedbackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.feedbackContentInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.feedbackContentInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.feedbackContentInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.feedbackContentInsets.bottom)
        }

        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.contentInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.contentInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.contentInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.contentInsets.right)
        }
    }
}

extension ChoiceElementView: ProcessedContentTextViewDelegate {
    func processedContentTextViewDidLoadContent(_ view: ProcessedContentTextView) {
        self.invalidateIntrinsicContentSize()
        self.onContentLoad?()
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenLink url: URL) { }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenImage url: URL) { }
}
