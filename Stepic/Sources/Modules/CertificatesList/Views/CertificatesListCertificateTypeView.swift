import SnapKit
import UIKit

extension CertificatesListCertificateTypeView {
    struct Appearance {
        let imageViewSize = CGSize(width: 14, height: 14)

        let textLabelFont = Typography.caption1Font
        let textLabelInsets = LayoutInsets(left: 4)

        let textLabelRegularTextColor = UIColor.stepikGreen
        let textLabelDistinctionTextColor = UIColor.stepikOrange
    }
}

final class CertificatesListCertificateTypeView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textLabelFont
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    var type = CertificateType.regular {
        didSet {
            self.updateStyle()
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.textLabel.intrinsicContentSize.height
        )
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

    private func updateStyle() {
        switch self.type {
        case .regular:
            self.imageView.image = UIImage(named: "certificates-list-certificate-regular")

            self.textLabel.text = NSLocalizedString("CertificatesListCertificateRegularTitle", comment: "")
            self.textLabel.textColor = self.appearance.textLabelRegularTextColor
        case .distinction:
            self.imageView.image = UIImage(named: "certificates-list-certificate-distinction")

            self.textLabel.text = NSLocalizedString("CertificatesListCertificateDistinctionTitle", comment: "")
            self.textLabel.textColor = self.appearance.textLabelDistinctionTextColor
        }
    }
}

extension CertificatesListCertificateTypeView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(self.textLabel.snp.centerY)
            make.size.equalTo(self.appearance.imageViewSize)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.textLabelInsets.left)
        }
    }
}
