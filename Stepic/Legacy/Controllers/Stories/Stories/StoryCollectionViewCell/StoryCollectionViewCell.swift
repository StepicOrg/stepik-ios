import Nuke
import UIKit

extension StoryCollectionViewCell {
    struct Appearance {
        let gradientImageViewCornerRadius: CGFloat = 15

        let backgroundContentViewCornerRadius: CGFloat = 13
        let backgroundContentViewBackgroundColor = UIColor.stepikBackground

        let titleLabelTextColor = UIColor.white
        let titleLabelFont = Typography.caption1Font

        let overlayViewBackgroundColor = UIColor.stepikAccentFixed.withAlphaComponent(0.5)
    }
}

final class StoryCollectionViewCell: UICollectionViewCell {
    let appearance = Appearance()

    @IBOutlet var gradientImageView: UIImageView!
    @IBOutlet var backgroundContentView: UIView!
    @IBOutlet var contentContainerView: UIView!
    @IBOutlet var overlayView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var imagePath: String = "" {
        didSet {
            if let url = URL(string: imagePath) {
                Nuke.loadImage(with: url, options: .shared, into: self.imageView)
            }
        }
    }

    var title: String = "" {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var isWatched: Bool = true {
        didSet {
            self.gradientImageView.isHidden = self.isWatched
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.gradientImageView.layer.cornerRadius = self.appearance.gradientImageViewCornerRadius
        self.gradientImageView.clipsToBounds = true
        self.gradientImageView.layer.masksToBounds = true

        [self.backgroundContentView, self.contentContainerView].forEach { view in
            view?.layer.cornerRadius = self.appearance.backgroundContentViewCornerRadius
            view?.clipsToBounds = true
            view?.layer.masksToBounds = true
        }

        self.backgroundContentView.backgroundColor = self.appearance.backgroundContentViewBackgroundColor
        self.overlayView.backgroundColor = self.appearance.overlayViewBackgroundColor

        self.titleLabel.textColor = self.appearance.titleLabelTextColor
        self.titleLabel.font = self.appearance.titleLabelFont

        self.update(imagePath: self.imagePath, title: self.title, isWatched: self.isWatched)
    }

    func update(imagePath: String, title: String, isWatched: Bool) {
        self.imagePath = imagePath
        self.title = title
        self.isWatched = isWatched
    }
}
