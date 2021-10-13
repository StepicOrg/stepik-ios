import UIKit

extension ContinueActionButton {
    struct Appearance {
        var titleFont = UIFont.systemFont(ofSize: 16)
        let titleInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let defaultBackgroundColor = UIColor.white
        var defaultTitleColor = UIColor.black.withAlphaComponent(0.87)

        let callToActionBackgroundColor = UIColor.stepikGreenFixed
        let callToActionTitleColor = UIColor.white
    }
}

final class ContinueActionButton: BounceButton {
    let appearance: Appearance

    private var shadowLayer: CAShapeLayer?

    var mode: Mode {
        didSet {
            self.updateAppearance()
        }
    }

    override var isEnabled: Bool {
        didSet {
            self.alpha = self.isEnabled ? 1.0 : 0.5
        }
    }

    init(
        frame: CGRect = .zero,
        mode: Mode = .default,
        appearance: Appearance = Appearance()
    ) {
        self.mode = mode
        self.appearance = appearance
        super.init(frame: frame)

        self.updateAppearance()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateAppearance()
    }

    private func updateAppearance() {
        self.titleLabel?.font = self.appearance.titleFont
        self.titleEdgeInsets = self.appearance.titleInsets

        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.height / 2

        switch self.mode {
        case .default:
            self.backgroundColor = self.appearance.defaultBackgroundColor
            self.setTitleColor(self.appearance.defaultTitleColor, for: .normal)
        case .callToAction:
            self.backgroundColor = self.appearance.callToActionBackgroundColor
            self.setTitleColor(self.appearance.callToActionTitleColor, for: .normal)
        }
    }

    enum Mode {
        /// Classic white button
        case `default`
        /// Green button
        case callToAction
    }
}
