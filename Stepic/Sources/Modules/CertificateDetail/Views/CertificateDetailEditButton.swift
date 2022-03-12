import SnapKit
import UIKit

extension CertificateDetailEditButton {
    struct Appearance {
        let tintColor = UIColor.stepikVioletFixed
        let font = Typography.bodyFont

        let imageSize = CGSize(width: 20, height: 20)
        let imageInsets = LayoutInsets(left: 16)

        let disabledAlpha: CGFloat = 0.5
    }
}

final class CertificateDetailEditButton: UIControl {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "edit")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.tintColor
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("CertificateDetailEditNameTitle", comment: "")
        label.font = self.appearance.font
        label.textColor = self.appearance.tintColor
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.alpha = 0.3
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.alpha = self.isEnabled ? 1.0 : self.appearance.disabledAlpha
                }
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            self.alpha = self.isEnabled ? 1.0 : self.appearance.disabledAlpha
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

extension CertificateDetailEditButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.imageSize)
            make.leading.equalToSuperview().offset(self.appearance.imageInsets.left)
            make.centerY.equalToSuperview()
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
