import SnapKit
import UIKit

extension NewProfileCertificatesCertificateWidgetView {
    struct Appearance {}
}

final class NewProfileCertificatesCertificateWidgetView: UIView {
    let appearance: Appearance

    private lazy var courseTitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()

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

    func configure(viewModel: NewProfileCertificatesCertificateViewModel) {
        self.courseTitleLabel.text = viewModel.courseTitle
    }
}

extension NewProfileCertificatesCertificateWidgetView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.courseTitleLabel)
    }

    func makeConstraints() {
        self.courseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.courseTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }
}
