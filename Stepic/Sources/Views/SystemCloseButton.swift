import SnapKit
import UIKit

extension SystemCloseButton {
    struct Appearance {
        let imageTintColor = UIColor.stepikAccent
        var imageSize: CGSize?
    }
}

/// A close button, similar to the UIBarButtonItem.SystemItem.close
final class SystemCloseButton: UIControl {
    let appearance: Appearance

    private lazy var blurView: UIVisualEffectView = {
        let style: UIBlurEffect.Style
        if #available(iOS 13.0, *) {
            style = .systemMaterial
        } else {
            style = .light
        }

        let blurView = UIVisualEffectView(effect: nil)
        blurView.effect = UIBlurEffect(style: style)
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false

        return blurView
    }()

    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "stories-close-button-icon")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.appearance.imageTintColor
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    override var isHighlighted: Bool {
        didSet {
            self.imageView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

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
        self.blurView.layer.cornerRadius = max(self.bounds.width, self.bounds.height) / 2
    }
}

extension SystemCloseButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.blurView)
        self.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.blurView.translatesAutoresizingMaskIntoConstraints = false
        self.blurView.snp.makeConstraints { make in
            make.center.width.height.equalToSuperview()
        }

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            if let imageSize = self.appearance.imageSize {
                make.center.equalToSuperview()
                make.width.height.equalTo(imageSize)
            } else {
                make.edges.equalToSuperview()
            }
        }
    }
}
