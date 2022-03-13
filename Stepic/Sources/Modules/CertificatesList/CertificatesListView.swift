import SnapKit
import UIKit

extension CertificatesListView {
    struct Appearance {}
}

final class CertificatesListView: UIView {
    let appearance: Appearance

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

extension CertificatesListView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {}

    func makeConstraints() {}
}
