//
//  ContinueActionButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension ContinueActionButton {
    struct Appearance {
        var titleFont = UIFont.systemFont(ofSize: 16)
        let titleInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let defaultBackgroundColor = UIColor.white
        let defaultTitleColor = UIColor.mainDark

        let callToActionBackgroundColor = UIColor.stepicGreen
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
