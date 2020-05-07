import Tabman
import UIKit

final class StepikLabelBarButton: TMLabelBarButton {
    enum Appearance {
        static let font = UIFont.systemFont(ofSize: 15, weight: .light)
        static let selectedFont = UIFont.systemFont(ofSize: 15)
        static let tintColor = UIColor.stepikPrimaryText
        static let selectedTintColor = UIColor.stepikPrimaryText
    }

    override func layout(in view: UIView) {
        super.layout(in: view)
        self.updateAppearance()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateAppearance()
        }
    }

    private func updateAppearance() {
        self.font = Appearance.font
        self.selectedFont = Appearance.selectedFont

        // Tabman correctly resolves only non-dynamic colors APPS-2854
        if #available(iOS 13.0, *) {
            self.tintColor = Appearance.tintColor.resolvedColor(with: self.traitCollection)
            self.selectedTintColor = Appearance.selectedTintColor.resolvedColor(with: self.traitCollection)
        } else {
            self.tintColor = Appearance.tintColor
            self.selectedTintColor = Appearance.selectedTintColor
        }
    }
}
