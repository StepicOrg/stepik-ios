import UIKit

extension CourseWidgetButton {
    struct Appearance {
        let cornerRadius: CGFloat = 8.0

        let titleFont = UIFont.systemFont(ofSize: 14, weight: .regular)

        var textColor = UIColor.mainText
        var backgroundColor = UIColor(hex: 0x535366, alpha: 0.06)

        var callToActionTextColor = UIColor.stepicGreen
        var callToActionBackgroundColor = UIColor.stepicGreen.withAlphaComponent(0.1)
    }
}

final class CourseWidgetButton: BounceButton {
    let appearance: Appearance

    var isCallToAction: Bool {
        didSet {
            self.updateColors()
        }
    }

    init(
        isCallToAction: Bool = false,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.isCallToAction = isCallToAction
        super.init(frame: .zero)
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateColors() {
        self.backgroundColor = self.isCallToAction
            ? self.appearance.callToActionBackgroundColor
            : self.appearance.backgroundColor
        self.setTitleColor(
            self.isCallToAction ? self.appearance.callToActionTextColor : self.appearance.textColor,
            for: .normal
        )
    }
}

extension CourseWidgetButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.titleLabel?.font = self.appearance.titleFont

        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius
    }
}
