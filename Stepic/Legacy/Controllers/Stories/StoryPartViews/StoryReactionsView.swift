import SnapKit
import UIKit

extension StoryReactionsView {
    struct Appearance {
        let imageSize = CGSize(width: 24, height: 24)
        let imageNormalTintColor = UIColor.white.withAlphaComponent(0.38)
        let imageSelectedTintColor = UIColor.white

        let tapProxyViewSize = CGSize(width: 48, height: 48)

        let spacing: CGFloat = 48
    }
}

final class StoryReactionsView: UIView {
    let appearance: Appearance

    private lazy var likeButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.image = UIImage(named: "stories-reaction-like")?.withRenderingMode(.alwaysTemplate)
        imageButton.imageSize = self.appearance.imageSize
        imageButton.tintColor = self.appearance.imageNormalTintColor
        imageButton.addTarget(self, action: #selector(self.likeButtonClicked), for: .touchUpInside)
        return imageButton
    }()
    private lazy var likeTapProxyView = TapProxyView(targetView: self.likeButton)

    private lazy var dislikeButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.image = UIImage(named: "stories-reaction-dislike")?.withRenderingMode(.alwaysTemplate)
        imageButton.imageSize = self.appearance.imageSize
        imageButton.tintColor = self.appearance.imageNormalTintColor
        imageButton.addTarget(self, action: #selector(self.dislikeButtonClicked), for: .touchUpInside)
        return imageButton
    }()
    private lazy var dislikeTapProxyView = TapProxyView(targetView: self.dislikeButton)

    var onLikeClick: (() -> Void)?
    var onDislikeClick: (() -> Void)?

    var state: State = .normal {
        didSet {
            switch self.state {
            case .normal:
                self.likeButton.tintColor = self.appearance.imageNormalTintColor
                self.dislikeButton.tintColor = self.appearance.imageNormalTintColor
            case .liked:
                self.likeButton.tintColor = self.appearance.imageSelectedTintColor
                self.dislikeButton.tintColor = self.appearance.imageNormalTintColor
            case .disliked:
                self.likeButton.tintColor = self.appearance.imageNormalTintColor
                self.dislikeButton.tintColor = self.appearance.imageSelectedTintColor
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: self.appearance.tapProxyViewSize.height)
    }

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
    private func likeButtonClicked() {
        self.state = .liked
        self.onLikeClick?()
    }

    @objc
    private func dislikeButtonClicked() {
        self.state = .disliked
        self.onDislikeClick?()
    }

    enum State {
        case normal
        case liked
        case disliked
    }
}

extension StoryReactionsView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.likeButton)
        self.addSubview(self.dislikeButton)
        self.addSubview(self.likeTapProxyView)
        self.addSubview(self.dislikeTapProxyView)
    }

    func makeConstraints() {
        self.likeButton.translatesAutoresizingMaskIntoConstraints = false
        self.likeButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.imageSize)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(-self.appearance.spacing)
        }

        self.dislikeButton.translatesAutoresizingMaskIntoConstraints = false
        self.dislikeButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.imageSize)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(self.appearance.spacing)
        }

        self.likeTapProxyView.translatesAutoresizingMaskIntoConstraints = false
        self.likeTapProxyView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.tapProxyViewSize)
            make.center.equalTo(self.likeButton.snp.center)
        }

        self.dislikeTapProxyView.translatesAutoresizingMaskIntoConstraints = false
        self.dislikeTapProxyView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.tapProxyViewSize)
            make.center.equalTo(self.dislikeButton.snp.center)
        }
    }
}
