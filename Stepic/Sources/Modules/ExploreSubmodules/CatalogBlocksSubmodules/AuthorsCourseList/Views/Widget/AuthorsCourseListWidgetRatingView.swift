import SnapKit
import UIKit

extension AuthorsCourseListWidgetRatingView {
    struct Appearance {
        let imageViewSize = CGSize(width: 16, height: 16)
        let imageViewTintColor = UIColor.stepikSystemSecondaryText

        let textLabelFont = Typography.caption1Font
        let textLabelTextColor = UIColor.stepikSystemSecondaryText
        let textLabelInsets = LayoutInsets(left: 4)
    }
}

final class AuthorsCourseListWidgetRatingView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.imageViewTintColor
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textLabelFont
        label.textColor = self.appearance.textLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }

    var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }

    override var intrinsicContentSize: CGSize {
        let width = self.appearance.imageViewSize.width
            + self.appearance.textLabelInsets.left
            + self.textLabel.intrinsicContentSize.width

        let maxHeight = max(
            self.appearance.imageViewSize.height,
            self.textLabel.intrinsicContentSize.height
        )

        return CGSize(width: width, height: maxHeight)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
}

extension AuthorsCourseListWidgetRatingView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.equalTo(self.appearance.imageViewSize.width)
            make.height.equalTo(self.appearance.imageViewSize.height)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.textLabelInsets.left)
            make.centerY.equalTo(self.imageView.snp.centerY)
            make.trailing.equalToSuperview()
        }
    }
}
