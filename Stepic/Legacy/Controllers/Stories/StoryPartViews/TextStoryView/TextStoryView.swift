import Nuke
import SnapKit
import UIKit

extension TextStoryView {
    struct Appearance {
        let textLabelFont = UIFont.systemFont(ofSize: 20, weight: .bold)

        let buttonFont = Typography.bodyFont
        let buttonHeight: CGFloat = 44

        let reactionsViewHeight: CGFloat = 48
        let reactionsViewInsets = LayoutInsets(bottom: 24)

        let elementsStackViewInsets = LayoutInsets(top: 68, left: 16, bottom: 24, right: 16)
        let elementsStackViewSpacing: CGFloat = 16

        let contentStackViewSpacing: CGFloat = 36
    }
}

final class TextStoryView: UIView, UIStoryPartViewProtocol {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    var appearance = Appearance()

    var completion: (() -> Void)?
    var onDidChangeReaction: ((StoryReaction) -> Void)?
    weak var urlNavigationDelegate: StoryURLNavigationDelegate?

    private var imagePath: String = ""
    private var storyPart: TextStoryPart?

    private let analytics: Analytics = StepikAnalytics.shared

    private lazy var gradientView = StoryPartGradientView()

    private lazy var elementsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = self.appearance.elementsStackViewSpacing
        return stackView
    }()

    private lazy var reactionsView: StoryReactionsView = {
        let view = StoryReactionsView()
        view.onLikeClick = { [weak self] in
            self?.onDidChangeReaction?(.like)
        }
        view.onDislikeClick = { [weak self] in
            self?.onDidChangeReaction?(.dislike)
        }
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.activityIndicator.isHidden = true

        self.insertSubview(self.gradientView, aboveSubview: self.imageView)
        self.gradientView.translatesAutoresizingMaskIntoConstraints = false
        self.gradientView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func configure(storyPart: TextStoryPart, urlNavigationDelegate: StoryURLNavigationDelegate?) {
        self.imagePath = storyPart.imagePath
        self.urlNavigationDelegate = urlNavigationDelegate

        self.setupReactionsView()
        self.setupElementsStackView()

        let topStackView = self.makeContentStackView()
        let bottomStackView = self.makeContentStackView()

        if let textModel = storyPart.text {
            if textModel.title != nil {
                let storyTitleView = self.makeTitleView(textModel: textModel)
                topStackView.addArrangedSubview(storyTitleView)
            }

            if textModel.text != nil {
                let storyTextView = self.makeTextView(textModel: textModel)
                bottomStackView.addArrangedSubview(storyTextView)
            }
        }

        if let button = storyPart.button {
            let storyButtonView = self.makeActionButtonView(button: button)
            bottomStackView.addArrangedSubview(storyButtonView)
        }

        self.elementsStackView.addArrangedSubview(topStackView)
        self.elementsStackView.addArrangedSubview(bottomStackView)
        self.elementsStackView.isHidden = true

        self.storyPart = storyPart
    }

    private func setupReactionsView() {
        self.addSubview(self.reactionsView)
        self.reactionsView.translatesAutoresizingMaskIntoConstraints = false
        self.reactionsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.reactionsViewInsets.bottom)
            make.height.equalTo(self.appearance.reactionsViewHeight)
        }
    }

    private func setupElementsStackView() {
        self.addSubview(self.elementsStackView)
        self.elementsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.elementsStackView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(self.appearance.elementsStackViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.elementsStackViewInsets.left)
            make.bottom.equalTo(self.reactionsView.snp.top).offset(-self.appearance.elementsStackViewInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.elementsStackViewInsets.right)
        }
    }

    private func makeContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.spacing = self.appearance.contentStackViewSpacing
        return stackView
    }

    private func makeTitleView(textModel: TextStoryPart.Text) -> UIView {
        let label = StoryPartTitleLabel(appearance: .init(textColor: textModel.textColor))
        label.text = textModel.title
        return label
    }

    private func makeTextView(textModel: TextStoryPart.Text) -> UIView {
        let label = UILabel()
        label.text = textModel.text
        label.textColor = textModel.textColor
        label.font = self.appearance.textLabelFont
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private func makeActionButtonView(button buttonModel: TextStoryPart.Button) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear

        let storyButton = WiderStepikButton(type: .system)
        storyButton.backgroundColor = buttonModel.backgroundColor
        storyButton.titleLabel?.font = self.appearance.buttonFont
        storyButton.setTitleColor(buttonModel.titleColor, for: .normal)
        storyButton.setTitle(buttonModel.title, for: .normal)

        let cornerRadius = self.appearance.buttonHeight / 2.0
        storyButton.setRoundedCorners(cornerRadius: cornerRadius)
        storyButton.widthDelta = cornerRadius * 2

        containerView.addSubview(storyButton)
        storyButton.translatesAutoresizingMaskIntoConstraints = false
        storyButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(self.appearance.buttonHeight)
        }

        storyButton.addTarget(self, action: #selector(self.actionButtonClicked), for: .touchUpInside)

        return containerView
    }

    func startLoad() {
        if self.activityIndicator.isHidden != false {
            self.activityIndicator.isHidden = false
            self.elementsStackView.isHidden = true
            self.activityIndicator.startAnimating()
        }

        guard let url = URL(string: self.imagePath) else {
            return
        }

        Nuke.loadImage(with: url, options: .shared, into: self.imageView, completion: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.activityIndicator.stopAnimating()
            strongSelf.activityIndicator.isHidden = true
            strongSelf.elementsStackView.isHidden = false
            strongSelf.completion?()
        })
    }

    func setReaction(_ reaction: StoryReaction?) {
        if let reaction = reaction {
            switch reaction {
            case .like:
                self.reactionsView.state = .liked
            case .dislike:
                self.reactionsView.state = .disliked
            }
        } else {
            self.reactionsView.state = .normal
        }
    }

    @objc
    func actionButtonClicked() {
        guard let part = self.storyPart,
              let path = part.button?.urlPath,
              let url = URL(string: path) else {
            return
        }

        self.analytics.send(.storyButtonPressed(id: part.storyID, position: part.position))
        self.urlNavigationDelegate?.open(url: url)
    }
}

private class WiderStepikButton: StepikButton {
    var widthDelta: CGFloat = 8 {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        super.intrinsicContentSize.sizeByDelta(dw: self.widthDelta, dh: 0)
    }
}
