import Atributika
import SnapKit
import UIKit

protocol QuizFeedbackViewDelegate: AnyObject {
    func quizFeedbackView(_ view: QuizFeedbackView, didRequestFullscreenImage url: URL)
    func quizFeedbackView(_ view: QuizFeedbackView, didRequestOpenURL url: URL)
}

extension QuizFeedbackView {
    struct Appearance {
        let cornerRadius: CGFloat = 6
        let titleFont = UIFont.systemFont(ofSize: 16)
        let titleMinHeight: CGFloat = 18
        let titleInsets = LayoutInsets(top: 15, left: 56, bottom: 15, right: 16)
        let leftViewInsets = LayoutInsets(left: 16, right: 16)

        let feedbackBackgroundColor = UIColor.stepikLightSecondaryBackground
        let feedbackContentInsets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

final class QuizFeedbackView: UIView {
    let appearance: Appearance

    weak var delegate: QuizFeedbackViewDelegate?

    private lazy var htmlToAttributedStringConverter = HTMLToAttributedStringConverter(font: self.appearance.titleFont)

    private lazy var titleLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.font = self.appearance.titleFont
        label.numberOfLines = 0
        return label
    }()

    private lazy var leftView = UIView()

    private lazy var feedbackView: ProcessedContentView = {
        var appearance = ProcessedContentView.Appearance()
        appearance.activityIndicatorViewStyle = .stepikGray
        appearance.backgroundColor = .clear

        let view = ProcessedContentView(appearance: appearance)
        view.delegate = self

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
        let titleLabelHeight = self.titleLabel.sizeThatFits(CGSize(width: self.bounds.width, height: .infinity)).height
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.titleInsets.top
                + self.appearance.titleInsets.bottom
                + max(self.appearance.titleMinHeight, titleLabelHeight)
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
        self.titleLabel.attributedText = self.htmlToAttributedStringConverter.convertToAttributedText(htmlString: title)
        self.titleLabel.textColor = state.titleColor
        self.titleContainerView.backgroundColor = state.mainColor

        self.titleLabel.sizeToFit()
        self.titleLabel.setNeedsLayout()

        self.leftView.subviews.forEach { $0.removeFromSuperview() }

        let view = state.leftView
        self.leftView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        if let hint = hint {
            self.feedbackView.processedContent = .html(hint)
        }

        self.animateFeedbackAppearance(showFeedback: hint != nil)
    }

    func setIconImage(_ image: UIImage?) {
        if let imageView = self.leftView.subviews.first as? UIImageView {
            imageView.image = image
        }
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
        case partiallyCorrect
        case wrong
        case evaluation
        case validation

        var mainColor: UIColor {
            switch self {
            case .correct:
                return .quizElementCorrectBackground
            case .partiallyCorrect:
                return .quizElementPartiallyCorrectBackground
            case .wrong:
                return .quizElementWrongBackground
            default:
                return .quizElementSelectedBackground
            }
        }

        var titleColor: UIColor {
            switch self {
            case .correct:
                return .stepikCallToActionText
            case .partiallyCorrect:
                return .stepikDarkYellow
            case .wrong:
                return .stepikLightRedFixed
            default:
                return .dynamic(light: .stepikVioletFixed, dark: .stepikExtraLightVioletFixed)
            }
        }

        var leftView: UIView {
            switch self {
            case .correct, .partiallyCorrect:
                let view = UIImageView(
                    image: UIImage(named: "quiz-feedback-correct")?.withRenderingMode(.alwaysTemplate)
                )
                view.contentMode = .scaleAspectFit
                view.tintColor = self.titleColor
                return view
            case .wrong:
                let view = UIImageView(
                    image: UIImage(named: "quiz-feedback-wrong")?.withRenderingMode(.alwaysTemplate)
                )
                view.contentMode = .scaleAspectFit
                view.tintColor = self.titleColor
                return view
            case .evaluation:
                let indicatorView = UIActivityIndicatorView(style: .stepikWhite)
                indicatorView.startAnimating()
                indicatorView.color = self.titleColor
                return indicatorView
            case .validation:
                let view = UIImageView(
                    image: UIImage(named: "quiz-feedback-info")?.withRenderingMode(.alwaysTemplate)
                )
                view.contentMode = .scaleAspectFit
                view.tintColor = self.titleColor
                return view
            }
        }

        init(quizStatus: QuizStatus) {
            switch quizStatus {
            case .wrong:
                self = .wrong
            case .correct:
                self = .correct
            case .partiallyCorrect:
                self = .partiallyCorrect
            case .evaluation:
                self = .evaluation
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

extension QuizFeedbackView: ProcessedContentViewDelegate {
    func processedContentView(_ view: ProcessedContentView, didReportNewHeight height: Int) {
        self.layoutIfNeeded()
        self.invalidateIntrinsicContentSize()
    }

    func processedContentView(_ view: ProcessedContentView, didOpenImageURL url: URL) {
        self.delegate?.quizFeedbackView(self, didRequestFullscreenImage: url)
    }

    func processedContentView(_ view: ProcessedContentView, didOpenLink url: URL) {
        self.delegate?.quizFeedbackView(self, didRequestOpenURL: url)
    }
}
