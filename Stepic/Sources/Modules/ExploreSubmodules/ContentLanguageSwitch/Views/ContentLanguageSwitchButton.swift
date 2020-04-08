import UIKit

final class ContentLanguageSwitchButton: BounceButton {
    enum Appearance {
        static let lightModeSelectedBackgroundColor = UIColor.stepikAccentFixed
        static let darkModeSelectedBackgroundColor = UIColor.stepikTertiaryBackground
        static let unselectedBackgroundColor = UIColor.stepikLightSecondaryBackground

        static let selectedTextColor = UIColor.white
        static let unselectedTextColor = UIColor.stepikSecondaryText

        static let font = UIFont.systemFont(ofSize: 16, weight: .light)
    }

    override var isSelected: Bool {
        didSet {
            self.updateViewColor()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateViewColor()
        }
    }

    private func updateViewColor() {
        if self.isSelected {
            self.setSelectedState()
        } else {
            self.setUnselectedState()
        }
    }

    private func setSelectedState() {
        self.backgroundColor = self.isDarkInterfaceStyle
            ? Appearance.darkModeSelectedBackgroundColor
            : Appearance.lightModeSelectedBackgroundColor
        self.titleLabel?.font = Appearance.font
        self.setTitleColor(Appearance.selectedTextColor, for: .selected)
    }

    private func setUnselectedState() {
        self.backgroundColor = Appearance.unselectedBackgroundColor
        self.titleLabel?.font = Appearance.font
        self.setTitleColor(Appearance.unselectedTextColor, for: .normal)
    }
}
