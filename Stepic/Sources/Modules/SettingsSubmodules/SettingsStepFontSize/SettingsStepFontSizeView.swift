import SnapKit
import UIKit

extension SettingsStepFontSizeView {
    struct Appearance { }
}

final class SettingsStepFontSizeView: UIView {
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

extension SettingsStepFontSizeView: ProgrammaticallyInitializableViewProtocol {
    func setupView() { }

    func addSubviews() { }

    func makeConstraints() { }
}