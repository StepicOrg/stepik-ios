import Nuke
import SnapKit
import UIKit

extension CertificateDetailPreviewView {
    struct Appearance {
        let imageViewHeightRatio: CGFloat = 3 / 4
        let imageViewPlaceholderImage = UIImage(named: "lesson_cover_50")
        let imageFadeInDuration: TimeInterval = 0.15
        let imageViewInsets = LayoutInsets(inset: 4)

        let backgroundColor = UIColor.stepikBackground
        let cornerRadius: CGFloat = 8

        let shadowColor = UIColor.black
        let shadowOffset = CGSize(width: 0, height: 1)
        let shadowRadius: CGFloat = 4.0
        let shadowOpacity: Float = 0.1
    }
}

final class CertificateDetailPreviewView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = self.appearance.cornerRadius
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView.init(style: .stepikGray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()

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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.shadowColor = self.appearance.shadowColor.cgColor
        self.layer.shadowOffset = self.appearance.shadowOffset
        self.layer.shadowRadius = self.appearance.shadowRadius
        self.layer.shadowOpacity = self.appearance.shadowOpacity
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.layer.cornerRadius
        ).cgPath
    }

    func loadImage(url: URL?) {
        if let url = url {
            self.activityIndicator.startAnimating()

            Nuke.loadImage(
                with: url,
                options: ImageLoadingOptions(
                    transition: ImageLoadingOptions.Transition.fadeIn(
                        duration: self.appearance.imageFadeInDuration
                    )
                ),
                into: self.imageView,
                completion: { [weak self] result in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.activityIndicator.stopAnimating()

                    if case .failure = result {
                        strongSelf.imageView.image = strongSelf.appearance.imageViewPlaceholderImage
                    }
                }
            )
        } else {
            self.activityIndicator.stopAnimating()
            self.imageView.image = self.appearance.imageViewPlaceholderImage
        }
    }
}

extension CertificateDetailPreviewView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor

        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.masksToBounds = true
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.activityIndicator)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(self.appearance.imageViewInsets.edgeInsets)
            make.height.equalTo(self.snp.width).multipliedBy(self.appearance.imageViewHeightRatio).priority(999)
        }

        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
