import SnapKit
import UIKit

extension NewProfileStreakNotificationsTimeSelectionView {
    struct Appearance {
        let titleLabelFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        let titleLabelTextColor = UIColor.stepikSystemPrimaryText
        let titleLabelInsets = LayoutInsets(left: 16)

        let detailLabelFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        let detailLabelTextColor = UIColor.stepikSystemSecondaryText
        let detailLabelInsets = LayoutInsets(left: 8)

        let detailDisclosureImageSize = CGSize(width: 11, height: 14)
        let detailDisclosureImageTintColor = UIColor.stepikSystemTertiaryText
        let detailDisclosureImageInsets = LayoutInsets(left: 8, right: 16)

        let backgroundColor = UIColor.stepikSecondaryGroupedBackground
    }
}

final class NewProfileStreakNotificationsTimeSelectionView: UIControl {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleLabelTextColor
        label.font = self.appearance.titleLabelFont
        label.numberOfLines = 1
        label.text = NSLocalizedString("NewProfileStreakNotificationsTimeSelection", comment: "")
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.detailLabelTextColor
        label.font = self.appearance.detailLabelFont
        label.numberOfLines = 1
        return label
    }()

    private lazy var detailDisclosureImageView: UIImageView = {
        let image = UIImage(named: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.appearance.detailDisclosureImageTintColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var detailText: String? {
        didSet {
            self.detailLabel.text = self.detailText
        }
    }

    override var isHighlighted: Bool {
        didSet {
            let alpha: CGFloat = self.isHighlighted ? 0.5 : 1.0
            self.titleLabel.alpha = alpha
            self.detailLabel.alpha = alpha
            self.detailDisclosureImageView.alpha = alpha
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
}

extension NewProfileStreakNotificationsTimeSelectionView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.detailLabel)
        self.addSubview(self.detailDisclosureImageView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.centerY.equalToSuperview()
        }

        self.detailLabel.translatesAutoresizingMaskIntoConstraints = false
        self.detailLabel.snp.makeConstraints { make in
            make.leading
                .greaterThanOrEqualTo(self.titleLabel.snp.trailing)
                .offset(self.appearance.detailLabelInsets.left)
            make.centerY.equalToSuperview()
        }

        self.detailDisclosureImageView.translatesAutoresizingMaskIntoConstraints = false
        self.detailDisclosureImageView.snp.makeConstraints { make in
            make.leading
                .equalTo(self.detailLabel.snp.trailing)
                .offset(self.appearance.detailDisclosureImageInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.detailDisclosureImageInsets.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(self.appearance.detailDisclosureImageSize.width)
            make.height.equalTo(self.appearance.detailDisclosureImageSize.height)
        }
    }
}
