import UIKit

extension NewProfileCertificatesCertificateCollectionViewCell {
    enum Appearance {
        static let borderWidth: CGFloat = 1.0
        static let cornerRadius: CGFloat = 13.0
    }
}

final class NewProfileCertificatesCertificateCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var widgetView = NewProfileCertificatesCertificateWidgetView()

    private var certificateType = CertificateType.regular

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            self.widgetView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateBorder()
    }

    func configure(viewModel: NewProfileCertificatesCertificateViewModel) {
        self.certificateType = viewModel.certificateType
        self.widgetView.configure(viewModel: viewModel)
        self.updateBorder()
    }

    private func updateBorder() {
        let borderColor: UIColor = {
            switch self.certificateType {
            case .distinction:
                return .stepikOrange
            case .regular:
                return .stepikGreen
            }
        }()

        self.layer.cornerRadius = Appearance.cornerRadius
        self.layer.borderWidth = Appearance.borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.masksToBounds = true
    }
}

extension NewProfileCertificatesCertificateCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.contentView.addSubview(self.widgetView)
    }

    func makeConstraints() {
        self.widgetView.translatesAutoresizingMaskIntoConstraints = false
        self.widgetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
