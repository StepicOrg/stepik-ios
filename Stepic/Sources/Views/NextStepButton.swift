import SnapKit
import UIKit

extension NextStepButton {
    struct Appearance {
        var titleColor = UIColor.dynamic(light: .white, dark: .stepikGreen)
        var font = UIFont.systemFont(ofSize: 16)

        var cornerRadius: CGFloat = 6
        var borderWidth: CGFloat = 1
        var borderColor = UIColor.dynamic(light: .clear, dark: .stepikGreen)

        var backgroundColor = UIColor.dynamic(light: .stepikGreen, dark: .stepikBackground)
    }
}

final class NextStepButton: UIButton {
    let appearance: Appearance

    override var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = self.appearance.borderColor.cgColor
    }
}

extension NextStepButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.setTitle(NSLocalizedString("NextStepNavigationTitle", comment: ""), for: .normal)
        self.setTitleColor(self.appearance.titleColor, for: .normal)
        self.titleLabel?.font = self.appearance.font

        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.borderWidth = self.appearance.borderWidth
        self.layer.borderColor = self.appearance.borderColor.cgColor
        self.clipsToBounds = true

        self.backgroundColor = self.appearance.backgroundColor
    }
}
