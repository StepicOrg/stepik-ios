import SnapKit
import UIKit

extension PromoBannerView {
    struct Appearance {
        let cornerRadius: CGFloat = 13

        let shadowColor = UIColor.black
        let shadowOffset = CGSize(width: 0, height: 1)
        let shadowRadius: CGFloat = 4.0
        let shadowOpacity: Float = 0.1

        let titleLabelFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        let titleLabelInsets = LayoutInsets(top: 16, left: 16)

        let subtitleLabelFont = Typography.caption2Font
        let subtitleLabelInsets = LayoutInsets(top: 8, left: 16, bottom: 16)
    }
}

final class PromoBannerView: UIControl {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleLabelFont
        label.numberOfLines = 0
        return label
    }()

    private lazy var illustrationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var backgroundColorView = UIView()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var subtitle: String? {
        didSet {
            self.subtitleLabel.text = self.subtitle
        }
    }

    var style = Style.green {
        didSet {
            self.updateStyle()
        }
    }

    var onClick: (() -> Void)?

    override var isHighlighted: Bool {
        didSet {
            self.animateBounce()
        }
    }

    override var intrinsicContentSize: CGSize {
        let titleHeightWithInsets = self.appearance.titleLabelInsets.top + self.titleLabel.intrinsicContentSize.height
        let subtitleHeightWithInsets = self.appearance.subtitleLabelInsets.top
            + self.subtitleLabel.intrinsicContentSize.height
            + self.appearance.subtitleLabelInsets.bottom

        let height = titleHeightWithInsets + subtitleHeightWithInsets

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

        self.updateStyle()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.masksToBounds = true

        self.backgroundColorView.layer.cornerRadius = self.appearance.cornerRadius
        self.backgroundColorView.clipsToBounds = true

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

    // MARK: Private API

    private func updateStyle() {
        self.backgroundColor = self.style == .green ? .white : .clear
        self.backgroundColorView.backgroundColor = self.style.backgroundColor

        self.illustrationImageView.image = self.style.illustrationImage

        self.titleLabel.textColor = self.style.titleLabelTextColor
        self.subtitleLabel.textColor = self.style.subtitleLabelTextColor
    }

    @objc
    private func handleTouchUpInside() {
        self.onClick?()
    }

    // MARK: Inner Types

    enum Style {
        case blue
        case green
        case violet

        fileprivate var backgroundColor: UIColor {
            switch self {
            case .blue:
                return .stepikOverlayDarkBlueFixed
            case .green:
                return .stepikOverlayGreenBackground
            case .violet:
                return .stepikViolet05Fixed
            }
        }

        fileprivate var titleLabelTextColor: UIColor { .black }

        fileprivate var subtitleLabelTextColor: UIColor {
            switch self {
            case .blue, .violet:
                return .white
            case .green:
                return .black.withAlphaComponent(0.6)
            }
        }

        fileprivate var illustrationImage: UIImage? {
            let imageName: String

            switch self {
            case .blue:
                imageName = "promo-banner-illustration-bicycle-green"
            case .green:
                imageName = "promo-banner-illustration-work"
            case .violet:
                imageName = "promo-banner-illustration-bicycle-violet"
            }

            return UIImage(named: imageName)
        }
    }
}

// MARK: - PromoBannerView: ProgrammaticallyInitializableViewProtocol -

extension PromoBannerView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.addTarget(self, action: #selector(self.handleTouchUpInside), for: .touchUpInside)
    }

    func addSubviews() {
        self.addSubview(self.backgroundColorView)
        self.addSubview(self.illustrationImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
    }

    func makeConstraints() {
        self.backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColorView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(self.appearance.titleLabelInsets.edgeInsets)
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.subtitleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.subtitleLabelInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.subtitleLabelInsets.bottom)
            make.width.equalToSuperview().multipliedBy(0.6)
        }

        self.illustrationImageView.translatesAutoresizingMaskIntoConstraints = false
        self.illustrationImageView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
        }
    }
}

extension PromoBannerView.Style {
    init(colorType: PromoBanner.ColorType) {
        switch colorType {
        case .blue:
            self = .blue
        case .green:
            self = .green
        case .violet:
            self = .violet
        }
    }
}
