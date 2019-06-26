import Nuke
import SnapKit
import UIKit

extension StepVideoPreviewView {
    struct Appearance {
        let overlayColor = UIColor.mainDark.withAlphaComponent(0.4)

        let introVideoHeightRatio: CGFloat = 9 / 16
        let thumbnailImageFadeInDuration: TimeInterval = 0.15

        let playImageTintColor = UIColor.white
        let playImageViewSize = CGSize(width: 25, height: 31)
    }
}

final class StepVideoPreviewView: UIControl {
    let appearance: Appearance

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.overlayColor
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private lazy var playImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "video-preview-play-overlay")?.withRenderingMode(.alwaysTemplate)
        )
        imageView.tintColor = self.appearance.playImageTintColor
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private lazy var gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.playClicked))

    var thumbnailImageURL: URL? {
        didSet {
            self.loadThumbnail()
        }
    }

    var onPlayClick: (() -> Void)?

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

    // MARK: Private API

    @objc
    private func playClicked() {
        self.onPlayClick?()
    }

    private func loadThumbnail() {
        if let thumbnailImageURL = self.thumbnailImageURL {
            Nuke.loadImage(
                with: thumbnailImageURL,
                options: .init(
                    placeholder: Images.videoPlaceholder,
                    transition: .fadeIn(duration: self.appearance.thumbnailImageFadeInDuration)
                ),
                into: self.thumbnailImageView
            )
        } else {
            self.thumbnailImageView.image = Images.videoPlaceholder
        }
    }
}

extension StepVideoPreviewView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white

        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(self.gestureRecognizer)
    }

    func addSubviews() {
        self.addSubview(self.thumbnailImageView)
        self.addSubview(self.overlayView)
        self.addSubview(self.playImageView)
    }

    func makeConstraints() {
        self.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        self.thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().priority(999)
            make.height.equalTo(self.snp.width).multipliedBy(self.appearance.introVideoHeightRatio).priority(999)
        }

        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.snp.makeConstraints { make in
            make.center.equalTo(self.thumbnailImageView)
            make.size.equalTo(self.thumbnailImageView)
        }

        self.playImageView.translatesAutoresizingMaskIntoConstraints = false
        self.playImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.playImageViewSize)
            make.center.equalTo(self.thumbnailImageView.snp.center)
        }
    }
}
