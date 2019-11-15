import SnapKit
import UIKit

extension DownloadsView {
    struct Appearance { }
}

// MARK: - DownloadsView: UIView -

final class DownloadsView: UIView {
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

// MARK: - DownloadsView: ProgrammaticallyInitializableViewProtocol -

extension DownloadsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() { }

    func makeConstraints() { }
}
