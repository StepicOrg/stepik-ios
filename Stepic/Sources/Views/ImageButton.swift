import UIKit

final class ImageButton: UIControl {
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.font
        return label
    }()

    private var additionalVerticalOffset: CGFloat = 0.0

    var imageSize = CGSize(width: 15, height: 15) {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    var imagePosition: Position = .left {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    var imageInsets = UIEdgeInsets.zero {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    var titleInsets = UIEdgeInsets.zero {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    override var tintColor: UIColor? {
        didSet {
            self.titleLabel.textColor = self.tintColor
            self.iconImageView.tintColor = self.tintColor
        }
    }

    var font = UIFont.systemFont(ofSize: 16) {
        didSet {
            self.titleLabel.font = self.font
            self.titleLabel.sizeToFit()

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
            self.titleLabel.sizeToFit()

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    var image: UIImage? {
        didSet {
            self.iconImageView.image = self.image
        }
    }

    // To be able to prevent alpha being changed on isEnabled state changes.
    var disabledAlpha: CGFloat = 0.5

    // To store private titleLabel
    // but sometimes we want to get direct reference to title view
    var titleContentView: UIView { self.titleLabel }

    override var intrinsicContentSize: CGSize {
        let titleWidth = self.titleInsets.left + self.titleLabel.frame.width + self.titleInsets.right
        let imageWidth = self.image != nil
            ? self.imageInsets.left + self.imageSize.width + self.imageInsets.right
            : 0.0
        let width = titleWidth + imageWidth

        let height = max(
            self.iconImageView.frame.maxY + self.imageInsets.bottom,
            self.titleLabel.frame.maxY + self.titleInsets.bottom
        )

        return CGSize(
            width: width,
            height: height + self.additionalVerticalOffset
        )
    }

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.alpha = 0.3
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.alpha = self.isEnabled ? 1.0 : self.disabledAlpha
                }
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            self.alpha = self.isEnabled ? 1.0 : self.disabledAlpha
        }
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let realHeight = max(
            self.imageInsets.top + self.imageSize.height + self.imageInsets.bottom,
            self.titleInsets.top + self.titleLabel.intrinsicContentSize.height + self.titleInsets.bottom
        )
        let heightDelta = self.frame.height - realHeight
        let additionalVerticalOffset = max(heightDelta, 0) / 2

        switch self.imagePosition {
        case .left:
            self.iconImageView.frame = self.image != nil
                ? CGRect(
                    origin: CGPoint(
                        x: self.imageInsets.left,
                        y: additionalVerticalOffset + self.imageInsets.top
                    ),
                    size: self.imageSize
                  )
                : .zero

            self.titleLabel.frame = CGRect(
                x: self.iconImageView.frame.maxX + self.titleInsets.left + self.imageInsets.right,
                y: additionalVerticalOffset + self.titleInsets.top,
                width: self.titleLabel.frame.width,
                height: self.titleLabel.frame.height
            )
        case .right:
            self.titleLabel.frame = CGRect(
                x: self.titleInsets.left,
                y: additionalVerticalOffset + self.titleInsets.top,
                width: self.titleLabel.frame.width,
                height: self.titleLabel.frame.height
            )

            self.iconImageView.frame = CGRect(
                x: self.titleLabel.frame.maxX + self.imageInsets.left + self.imageInsets.right,
                y: additionalVerticalOffset + self.imageInsets.top,
                width: self.imageSize.width,
                height: self.imageSize.height
            )
        }

        self.additionalVerticalOffset = additionalVerticalOffset

        self.invalidateIntrinsicContentSize()
    }

    private func setupView() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
    }

    enum Position {
        case left
        case right
    }
}
