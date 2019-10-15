import SnapKit
import UIKit

extension NewDiscussionsView {
    struct Appearance { }
}

final class NewDiscussionsView: UIView {
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

extension NewDiscussionsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() { }

    func addSubviews() { }

    func makeConstraints() { }
}