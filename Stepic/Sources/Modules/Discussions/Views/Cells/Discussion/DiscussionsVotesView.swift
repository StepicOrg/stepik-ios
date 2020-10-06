import SnapKit
import UIKit

extension DiscussionsVotesView {
    struct Appearance {
        let imageSize = CGSize(width: 20, height: 20)
        let font = UIFont.systemFont(ofSize: 12, weight: .light)
        let spacing: CGFloat = 16

        let filledTintColor = UIColor.stepikAccent
        let normalTintColor = UIColor.stepikAccentAlpha50
        let disabledTintColor = UIColor.stepikAccentAlpha25

        let likeButtonTitleInsets = UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 0)
        let dislikeButtonTitleInsets = UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 0)
    }
}

final class DiscussionsVotesView: UIView {
    let appearance: Appearance

    private lazy var likeImageButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.imageSize = self.appearance.imageSize
        imageButton.tintColor = self.appearance.normalTintColor
        imageButton.font = self.appearance.font
        imageButton.title = "0"
        imageButton.image = UIImage(named: "discussions-thumb-up")?.withRenderingMode(.alwaysTemplate)
        imageButton.titleInsets = self.appearance.likeButtonTitleInsets
        imageButton.addTarget(self, action: #selector(self.likeImageButtonClicked), for: .touchUpInside)
        return imageButton
    }()

    private lazy var dislikeImageButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.imageSize = self.appearance.imageSize
        imageButton.tintColor = self.appearance.normalTintColor
        imageButton.font = self.appearance.font
        imageButton.title = "0"
        imageButton.image = UIImage(named: "discussions-thumb-down")?.withRenderingMode(.alwaysTemplate)
        imageButton.titleInsets = self.appearance.dislikeButtonTitleInsets
        imageButton.addTarget(self, action: #selector(self.dislikeImageButtonClicked), for: .touchUpInside)
        return imageButton
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    var likesCount: Int = 0 {
        didSet {
            self.likeImageButton.title = "\(self.likesCount)"
        }
    }

    var dislikesCount: Int = 0 {
        didSet {
            self.dislikeImageButton.title = "\(self.dislikesCount)"
        }
    }

    var state: State = .normal {
        didSet {
            switch self.state {
            case .liked:
                self.likeImageButton.tintColor = self.appearance.filledTintColor
                self.dislikeImageButton.tintColor = self.appearance.normalTintColor
                self.isEnabled = true
            case .disliked:
                self.likeImageButton.tintColor = self.appearance.normalTintColor
                self.dislikeImageButton.tintColor = self.appearance.filledTintColor
                self.isEnabled = true
            case .normal:
                self.likeImageButton.tintColor = self.appearance.normalTintColor
                self.dislikeImageButton.tintColor = self.appearance.normalTintColor
                self.isEnabled = true
            case .disabled:
                self.likeImageButton.tintColor = self.appearance.disabledTintColor
                self.dislikeImageButton.tintColor = self.appearance.disabledTintColor
                self.isEnabled = false
            }
        }
    }

    var isEnabled: Bool = true {
        didSet {
            self.likeImageButton.isEnabled = self.isEnabled
            self.dislikeImageButton.isEnabled = self.isEnabled
        }
    }

    var onLikeClick: (() -> Void)?
    var onDislikeClick: (() -> Void)?

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func likeImageButtonClicked() {
        self.onLikeClick?()
    }

    @objc
    private func dislikeImageButtonClicked() {
        self.onDislikeClick?()
    }

    enum State {
        case liked
        case disliked
        case normal
        case disabled
    }
}

extension DiscussionsVotesView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.likeImageButton)
        self.stackView.addArrangedSubview(self.dislikeImageButton)
    }

    func makeConstraints() {
        self.stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
