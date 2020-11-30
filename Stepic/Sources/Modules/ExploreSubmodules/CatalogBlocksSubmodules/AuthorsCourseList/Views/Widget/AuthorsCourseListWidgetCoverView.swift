import Nuke
import SnapKit
import UIKit

extension AuthorsCourseListWidgetCoverView {
    struct Appearance {
        let coverImagePlaceholderImage = UIImage(named: "lesson_cover_50")
        let coverImageFadeInDuration: TimeInterval = 0.15

        let cornerRadius: CGFloat = 8
    }
}

final class AuthorsCourseListWidgetCoverView: UIView {
    let appearance: Appearance

    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(image: self.appearance.coverImagePlaceholderImage)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    var coverImageURL: URL? {
        didSet {
            self.loadImage(url: self.coverImageURL)
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

    private func loadImage(url: URL?) {
        if let url = url {
            Nuke.loadImage(
                with: url,
                options: ImageLoadingOptions(
                    placeholder: self.appearance.coverImagePlaceholderImage,
                    transition: ImageLoadingOptions.Transition.fadeIn(
                        duration: self.appearance.coverImageFadeInDuration
                    )
                ),
                into: self.coverImageView,
                completion: nil
            )
        } else {
            self.coverImageView.image = self.appearance.coverImagePlaceholderImage
        }
    }
}

extension AuthorsCourseListWidgetCoverView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.layer.cornerRadius = self.appearance.cornerRadius
        self.clipsToBounds = true
    }

    func addSubviews() {
        self.addSubview(self.coverImageView)
    }

    func makeConstraints() {
        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
