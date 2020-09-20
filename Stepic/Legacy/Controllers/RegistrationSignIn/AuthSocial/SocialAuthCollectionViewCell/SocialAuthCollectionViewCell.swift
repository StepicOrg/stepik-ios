import SnapKit
import UIKit

extension SocialAuthCollectionViewCell {
    struct Appearance {
        let borderColor = UIColor.black
        let borderWidth: CGFloat = 0.5
        let cornerRadius: CGFloat = 8

        let backgroundColor = UIColor.white

        let imageViewWidthHeight: CGFloat = 48
    }
}

final class SocialAuthCollectionViewCell: UICollectionViewCell, Reusable {
    var appearance = Appearance()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()

    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.alpha = 0.3
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.alpha = 1.0
                }
            }
        }
    }

    override init(frame: CGRect) {
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

        if self.isDarkInterfaceStyle {
            self.layer.borderColor = nil
            self.layer.borderWidth = 0
        } else {
            self.layer.borderColor = self.appearance.borderColor.cgColor
            self.layer.borderWidth = self.appearance.borderWidth
        }
    }
}

extension SocialAuthCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = false

        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.masksToBounds = true

        self.contentView.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.contentView.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(self.appearance.imageViewWidthHeight)
        }
    }
}
