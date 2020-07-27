import Nuke
import SnapKit
import UIKit

extension NewProfileCoverView {
    struct Appearance {
        let imageFadeInDuration: TimeInterval = 0.15
        let placeholderImage = UIImage(named: "lesson_cover_50")
        let overlayColor = UIColor.stepikAccentFixed
        let overlayAlpha: CGFloat = 0.25
        let activityIndicatorColor = UIColor.stepikLoadingIndicator
    }
}

final class NewProfileCoverView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.overlayColor
        view.alpha = self.appearance.overlayAlpha
        return view
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .stepikGray)
        activityIndicatorView.color = self.appearance.activityIndicatorColor
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()

    var imageURL: URL? {
        didSet {
            if let imageURL = self.imageURL {
                self.loadImage(imageURL)
            } else {
                self.imageView.image = nil
            }
        }
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

    private func loadImage(_ url: URL) {
        DispatchQueue.main.async {
            if self.imageView.image == nil {
                self.activityIndicatorView.startAnimating()
            }
        }

        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions(
                transition: ImageLoadingOptions.Transition.fadeIn(
                    duration: self.appearance.imageFadeInDuration
                ),
                failureImage: self.appearance.placeholderImage
            ),
            into: self.imageView,
            completion: { [weak self] _ in
                self?.activityIndicatorView.stopAnimating()
            }
        )
    }
}

extension NewProfileCoverView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.overlayView)
        self.addSubview(self.activityIndicatorView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicatorView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
