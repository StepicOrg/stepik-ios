import SnapKit
import UIKit

extension CertificatesListCellSkeletonView {
    struct Appearance {
        let cardViewHeight: CGFloat = 142

        let cornerRadius: CGFloat = 16

        let defaultLayoutInsets = LayoutInsets.default
    }
}

final class CertificatesListCellSkeletonView: UIView {
    let appearance: Appearance

    private lazy var cardView = UIView()

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

extension CertificatesListCellSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.cardView.clipsToBounds = true
        self.cardView.layer.cornerRadius = self.appearance.cornerRadius
    }

    func addSubviews() {
        self.addSubview(self.cardView)
    }

    func makeConstraints() {
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(self.appearance.defaultLayoutInsets.edgeInsets)
            make.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.cardViewHeight)
        }
    }
}
