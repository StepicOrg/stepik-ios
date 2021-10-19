import SnapKit
import UIKit

extension CourseInfoPurchaseModalActionButton {
    struct Appearance {
        let iconImageViewSize = CGSize(width: 18, height: 22)
        let iconImageViewInsets = LayoutInsets(left: 16)
        var iconImageViewTintColor: UIColor?

        let textLabelFont = Typography.bodyFont
        var textLabelTextColor = UIColor.white

        var backgroundColor = UIColor.stepikVioletFixed

        var borderWidth: CGFloat = 0
        var borderColor: UIColor?
        let cornerRadius: CGFloat = 8
    }
}

final class CourseInfoPurchaseModalActionButton: UIControl {
    var appearance: Appearance {
        didSet {
            self.updateAppearance()
        }
    }

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    var iconImage: UIImage? {
        didSet {
            self.iconImageView.image = self.iconImage
            self.iconImageView.isHidden = self.iconImage == nil
        }
    }

    var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }

    var attributedText: NSAttributedString? {
        didSet {
            self.textLabel.attributedText = self.attributedText
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.5 : 1.0
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

        self.updateAppearance()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateBorder()
        }
    }

    private func updateAppearance() {
        if let iconImageViewTintColor = self.appearance.iconImageViewTintColor {
            self.iconImageView.tintColor = iconImageViewTintColor
        }

        self.textLabel.font = self.appearance.textLabelFont
        self.textLabel.textColor = self.appearance.textLabelTextColor

        self.backgroundColor = self.appearance.backgroundColor

        self.updateBorder()
    }

    private func updateBorder() {
        self.layer.borderWidth = self.appearance.borderWidth
        self.layer.borderColor = self.appearance.borderColor?.cgColor
    }
}

extension CourseInfoPurchaseModalActionButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

    func addSubviews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.iconImageViewInsets.left)
            make.size.equalTo(self.appearance.iconImageViewSize)
            make.centerY.equalTo(self.textLabel.snp.centerY)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
