import SnapKit
import UIKit

// MARK: Appearance -

extension EditStepView {
    struct Appearance { }
}

// MARK: - EditStepView: UIView -

final class EditStepView: UIView {
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

extension EditStepView: ProgrammaticallyInitializableViewProtocol {
    func setupView() { }

    func addSubviews() { }

    func makeConstraints() { }
}
