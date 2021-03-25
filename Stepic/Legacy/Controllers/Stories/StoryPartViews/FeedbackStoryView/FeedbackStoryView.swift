import Nuke
import SnapKit
import UIKit

extension FeedbackStoryView {
    struct Appearance {
        let backgroundColor = UIColor.stepikAccentFixed

        let titleLabelInsets = LayoutInsets(top: 68, left: 16, bottom: 20, right: 16)

        let actionButtonImageSize = CGSize(width: 14, height: 18)
        let actionButtonImageInsets = LayoutInsets(right: 8)
        let actionButtonHeight: CGFloat = 44
        let actionButtonInsets = LayoutInsets(top: 20, bottom: 48)
    }
}

final class FeedbackStoryView: UIView, UIStoryPartViewProtocol {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        return activityIndicator
    }()

    private lazy var gradientView = StoryPartGradientView()

    private lazy var titleLabel = StoryPartTitleLabel()

    private lazy var formView = FeedbackStoryFormView()

    private lazy var actionButton: ImageButton = {
        let button = ImageButton()
        button.imageSize = self.appearance.actionButtonImageSize
        button.addTarget(self, action: #selector(self.actionButtonClicked), for: .touchUpInside)

        let cornerRadius = self.appearance.actionButtonHeight / 2
        button.setRoundedCorners(cornerRadius: cornerRadius)

        button.titleInsets = .init(top: 0, left: cornerRadius, bottom: 0, right: cornerRadius)

        return button
    }()

    private let analytics: Analytics = StepikAnalytics.shared

    private var storyPart: FeedbackStoryPart?

    var completion: (() -> Void)?

    var onDidChangeReaction: ((StoryReaction) -> Void)?

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

    // MARK: - Public API

    func configure(storyPart: FeedbackStoryPart) {
        self.storyPart = storyPart

        if let textModel = storyPart.text {
            self.titleLabel.text = textModel.title
            self.titleLabel.textColor = textModel.textColor
        }

        if let buttonModel = storyPart.button {
            self.actionButton.title = buttonModel.title
            self.actionButton.backgroundColor = buttonModel.backgroundColor
            self.actionButton.tintColor = buttonModel.titleColor
        }

        if let feedbackModel = storyPart.feedback {
            self.formView.backgroundColor = feedbackModel.backgroundColor
            self.formView.title = feedbackModel.text
            self.formView.titleTextColor = feedbackModel.textColor
            self.formView.iconImage = feedbackModel.iconStyle.image
            self.formView.inputBackgroundColor = feedbackModel.inputBackgroundColor
            self.formView.inputTextColor = feedbackModel.inputTextColor
            self.formView.inputPlaceholderText = feedbackModel.placeholderText
            self.formView.inputPlaceholderTextColor = feedbackModel.placeholderTextColor
        }

        self.setContentHidden(true)
    }

    // MARK: UIStoryPartViewProtocol

    func startLoad() {
        guard let imagePath = self.storyPart?.imagePath,
              let imageURL = URL(string: imagePath) else {
            return
        }

        self.setContentHidden(true)
        self.activityIndicator.startAnimating()

        Nuke.loadImage(with: imageURL, options: .shared, into: self.imageView, completion: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.activityIndicator.stopAnimating()
            strongSelf.setContentHidden(false)
            strongSelf.completion?()
        })
    }

    func setReaction(_ reaction: StoryReaction?) {}

    // MARK: Private API

    private func setContentHidden(_ isHidden: Bool) {
        [self.titleLabel, self.formView, self.actionButton].forEach { $0.isHidden = isHidden }
    }

    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        _ = self.formView.resignFirstResponder()
    }

    @objc
    private func actionButtonClicked() {
        guard let storyPart = self.storyPart else {
            return
        }

        let feedback = self.formView.inputText.trimmed()
        if feedback.isEmpty {
            return
        }

        self.formView.isUserInteractionEnabled = false

        self.actionButton.title = storyPart.button?.feedbackTitle
        self.actionButton.image = UIImage(named: "quiz-mark-correct")?.withRenderingMode(.alwaysTemplate)
        self.actionButton.imageInsets = .init(
            top: 0,
            left: self.actionButton.layer.cornerRadius,
            bottom: 0,
            right: self.appearance.actionButtonImageInsets.right
        )
        self.actionButton.titleInsets = .init(top: 0, left: 0, bottom: 0, right: self.actionButton.layer.cornerRadius)
        self.actionButton.isUserInteractionEnabled = false

        self.endEditing(true)

        self.analytics.send(
            .storyFeedbackPressed(id: storyPart.storyID, position: storyPart.position, feedback: feedback)
        )
    }
}

// MARK: - FeedbackStoryView: ProgrammaticallyInitializableViewProtocol -

extension FeedbackStoryView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor

        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.handleTap(recognizer:))
        )
        gestureRecognizer.delegate = self
        self.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.cancelsTouchesInView = false
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.gradientView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.formView)
        self.addSubview(self.actionButton)
        self.addSubview(self.activityIndicator)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.gradientView.translatesAutoresizingMaskIntoConstraints = false
        self.gradientView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(self.appearance.titleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.bottom.lessThanOrEqualTo(self.formView.snp.top).offset(-self.appearance.titleLabelInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.titleLabelInsets.right)
        }

        self.formView.translatesAutoresizingMaskIntoConstraints = false
        self.formView.snp.makeConstraints { make in
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.trailing.equalTo(self.titleLabel.snp.trailing)
        }

        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.snp.makeConstraints { make in
            make.top.equalTo(self.formView.snp.bottom).offset(self.appearance.actionButtonInsets.top)
            make.leading.equalTo(self.formView.snp.leading)
            make.bottom.equalToSuperview().offset(-self.appearance.actionButtonInsets.bottom)
            make.height.equalTo(self.appearance.actionButtonHeight)
        }

        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
    }
}

// MARK: - FeedbackStoryView: UIGestureRecognizerDelegate -

extension FeedbackStoryView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.formView.isFirstResponder
    }
}
