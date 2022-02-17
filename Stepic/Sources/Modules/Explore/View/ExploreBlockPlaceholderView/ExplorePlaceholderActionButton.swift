import SnapKit
import UIKit

extension ExplorePlaceholderActionButton {
    struct Appearance {
        let imageSize = CGSize(width: 20, height: 20)
        let insets = LayoutInsets(inset: 12)

        let tintColor = UIColor.stepikVioletFixed
        let font = Typography.bodyFont

        let cornerRadius: CGFloat = 8
        let borderWidth: CGFloat = 1
        let borderColor = UIColor(hex6: 0x6C7BDF).withAlphaComponent(0.12)
    }
}

final class ExplorePlaceholderActionButton: UIControl {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.font
        label.textColor = self.appearance.tintColor
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = self.appearance.tintColor
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
            self.imageView.isHidden = self.image == nil
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.titleLabel.alpha = self.isHighlighted ? 0.5 : 1.0
            self.imageView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override var intrinsicContentSize: CGSize {
        let imageWidthWithInsets = self.appearance.insets.left + self.appearance.imageSize.width
        let width = imageWidthWithInsets
            + self.appearance.insets.left
            + self.titleLabel.intrinsicContentSize.width
            + self.appearance.insets.right

        let height = max(
            self.appearance.imageSize.height,
            self.titleLabel.intrinsicContentSize.height
        ) + self.appearance.insets.top + self.appearance.insets.bottom

        return CGSize(width: width, height: height)
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
}

extension ExplorePlaceholderActionButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.borderWidth = self.appearance.borderWidth
        self.layer.borderColor = self.appearance.borderColor.cgColor
        self.clipsToBounds = true
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.size.equalTo(self.appearance.imageSize)
            make.centerY.equalToSuperview()
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
    }
}
