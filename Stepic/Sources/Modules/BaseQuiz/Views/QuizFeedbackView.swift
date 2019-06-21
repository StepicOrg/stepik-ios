import SnapKit
import UIKit

extension QuizFeedbackView {
    struct Appearance {
        let cornerRadius: CGFloat = 6
        let titleFont = UIFont.systemFont(ofSize: 16)
        let titleMinHeight: CGFloat = 18
        let titleInsets = LayoutInsets(top: 15, left: 56, bottom: 15, right: 16)
        let leftViewInsets = LayoutInsets(left: 16, right: 16)

        let feedbackBackgroundColor = UIColor(hex: 0xF6F6F6)
        let feedbackContentInsets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

final class QuizFeedbackView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.numberOfLines = 0
        return label
    }()

    private lazy var leftView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var feedbackView: ProcessedContentTextView = {
        let view = ProcessedContentTextView()
        return view
    }()

    private lazy var titleContainerView = UIView()

    private lazy var feedbackContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = self.appearance.feedbackBackgroundColor
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.titleContainerView, self.feedbackContainerView])
        stackView.axis = .vertical
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.titleInsets.top
                + self.appearance.titleInsets.bottom
                + max(self.appearance.titleMinHeight, self.titleLabel.intrinsicContentSize.height)
        )
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
        self.invalidateIntrinsicContentSize()

        DispatchQueue.main.async {
            self.updateCornersForTitle(showFeedback: !self.feedbackContainerView.isHidden)
            self.updateCornersForFeedback()
        }
    }

    // MARK: Public API

    func update(state: State, title: String, hint: String? = nil) {
        self.titleLabel.text = title
        self.titleLabel.textColor = state.titleColor
        self.titleContainerView.backgroundColor = state.mainColor

        self.leftView.subviews.forEach { $0.removeFromSuperview() }

        let view = state.leftView
        self.leftView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.animateFeedbackAppearance(showFeedback: hint != nil)
    }

    // MARK: Private API

    private func animateFeedbackAppearance(showFeedback: Bool) {
        if showFeedback {
            self.feedbackContainerView.isHidden = false
        } else {
            self.feedbackContainerView.isHidden = true
        }
    }

    private func updateCornersForTitle(showFeedback: Bool) {
        let path = UIBezierPath(
            roundedRect: self.titleContainerView.bounds,
            byRoundingCorners: showFeedback ? [.topLeft, .topRight] : .allCorners,
            cornerRadii: CGSize(width: self.appearance.cornerRadius, height: self.appearance.cornerRadius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.titleContainerView.layer.mask = mask
    }

    private func updateCornersForFeedback() {
        let path = UIBezierPath(
            roundedRect: self.feedbackContainerView.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: self.appearance.cornerRadius, height: self.appearance.cornerRadius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.feedbackContainerView.layer.mask = mask
    }

    // MARK: Enums

    enum State {
        case correct
        case wrong
        case evaluation
        case validation

        var mainColor: UIColor {
            switch self {
            case .correct:
                return UIColor(hex: 0xE9F9E9)
            case .wrong:
                return UIColor(hex: 0xFF7965).withAlphaComponent(0.15)
            default:
                return UIColor(hex: 0xE9EBFA)
            }
        }

        var titleColor: UIColor {
            switch self {
            case .correct:
                return UIColor(hex: 0x66CC66)
            case .wrong:
                return UIColor(hex: 0xFF7965)
            default:
                return UIColor(hex: 0x6C7BDF)
            }
        }

        var leftView: UIView {
            switch self {
            case .correct:
                let view = UIImageView(
                    image: UIImage(named: "quiz-feedback-correct")?.withRenderingMode(.alwaysTemplate)
                )
                view.tintColor = self.titleColor
                return view
            case .wrong:
                let view = UIImageView(
                    image: UIImage(named: "quiz-feedback-wrong")?.withRenderingMode(.alwaysTemplate)
                )
                view.tintColor = self.titleColor
                return view
            case .evaluation:
                let indicatorView = UIActivityIndicatorView(style: .white)
                indicatorView.startAnimating()
                indicatorView.color = self.titleColor
                return indicatorView
            case .validation:
                let view = UIImageView(
                    image: UIImage(named: "quiz-feedback-info")?.withRenderingMode(.alwaysTemplate)
                )
                view.tintColor = self.titleColor
                return view
            }
        }
    }
}

extension QuizFeedbackView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)

        self.titleContainerView.addSubview(self.titleLabel)
        self.titleContainerView.addSubview(self.leftView)

        self.feedbackContainerView.addSubview(self.feedbackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().offset(self.appearance.titleInsets.top)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.titleInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.titleInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
        }

        self.leftView.translatesAutoresizingMaskIntoConstraints = false
        self.leftView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.leftViewInsets.left)
            make.trailing.equalTo(self.titleLabel.snp.leading).offset(-self.appearance.leftViewInsets.right)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }

        self.feedbackView.translatesAutoresizingMaskIntoConstraints = false
        self.feedbackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.feedbackContentInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.feedbackContentInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.feedbackContentInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.feedbackContentInsets.bottom)
        }
    }
}
