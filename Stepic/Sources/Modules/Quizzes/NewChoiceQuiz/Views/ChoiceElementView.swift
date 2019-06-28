import SnapKit
import UIKit

extension ChoiceElementView {
    struct Appearance {
        let contentInsets = LayoutInsets(top: 12, left: 16, bottom: 12, right: 16)

        let shadowColor = UIColor(hex: 0xEAECF0)
        let shadowOffset = CGSize(width: 0, height: 1)
        let shadowRadius: CGFloat = 4
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

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.contentView.intrinsicContentSize.height
                + self.appearance.contentInsets.top
                + self.appearance.contentInsets.bottom
        )
    }

    var state = State.default {
        didSet {
            self.updateState()
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.shadowView.layer.shadowPath = UIBezierPath(
            roundedRect: self.shadowView.bounds,
            cornerRadius: self.quizElementView.appearance.cornerRadius
        ).cgPath
    }

    // MARK: - Private API

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

        self.shadowView.isHidden = self.state != .selected && self.state != .default
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

        self.contentView.loadHTMLText("test")
    }

    func addSubviews() {
        self.addSubview(self.quizElementView)
        self.addSubview(self.contentView)

        self.insertSubview(self.shadowView, belowSubview: self.quizElementView)
    }

    func makeConstraints() {
        self.shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowView.snp.makeConstraints { make in
            make.center.equalTo(self.quizElementView)
            make.size.equalTo(self.quizElementView)
        }

        self.quizElementView.translatesAutoresizingMaskIntoConstraints = false
        self.quizElementView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
