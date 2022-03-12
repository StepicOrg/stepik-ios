import SnapKit
import UIKit

extension CertificateDetailGradeView {
    struct Appearance {
        let imageViewSize = CGSize(width: 18, height: 18)

        let textLabelFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let textLabelTextColor = UIColor.stepikMaterialPrimaryText
        let textLabelInsets = LayoutInsets(left: 8)
    }
}

final class CertificateDetailGradeView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textLabelFont
        label.textColor = self.appearance.textLabelTextColor
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    var badgeStyle = BadgeStyle.regular {
        didSet {
            self.imageView.image = self.badgeStyle.image
        }
    }

    var text: String? {
        didSet {
            self.textLabel.text = self.text
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = max(self.appearance.imageViewSize.height, self.textLabel.intrinsicContentSize.height)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
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

    enum BadgeStyle {
        case regular
        case distinction

        fileprivate var image: UIImage? {
            let imageName: String

            switch self {
            case .regular:
                imageName = "certificate-detail-badge-regular"
            case .distinction:
                imageName = "certificate-detail-badge-distinction"
            }

            return UIImage(named: imageName)
        }
    }
}

extension CertificateDetailGradeView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.size.equalTo(self.appearance.imageViewSize)
            make.centerY.equalToSuperview()
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.textLabelInsets.left)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.imageView.snp.centerY)
        }
    }
}
