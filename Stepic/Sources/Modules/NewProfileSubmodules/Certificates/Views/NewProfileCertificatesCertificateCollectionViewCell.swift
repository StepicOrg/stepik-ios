import UIKit

extension NewProfileCertificatesCertificateCollectionViewCell {
    enum Appearance {
        static let borderWidth: CGFloat = 1.0
        static let cornerRadius: CGFloat = 13.0
    }
}

final class NewProfileCertificatesCertificateCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var widgetView = NewProfileCertificatesCertificateWidgetView()

    override init(frame: CGRect) {
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

        self.layer.cornerRadius = Appearance.cornerRadius
        self.layer.borderWidth = Appearance.borderWidth
        self.layer.borderColor = UIColor.stepikGreen.cgColor
        self.layer.masksToBounds = true
    }

    func configure(viewModel: NewProfileCertificatesCertificateViewModel) {
        self.widgetView.configure(viewModel: viewModel)
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
