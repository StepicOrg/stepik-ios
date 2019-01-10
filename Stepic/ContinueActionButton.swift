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
        var cornerRadius: CGFloat = 33.0
        var titleFont = UIFont.systemFont(ofSize: 16)
        let titleInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let shadowOffset = CGSize(width: 0, height: 1.3)
        let shadowOpacity: Float = 1.0
        let shadowRadius: CGFloat = 6.7

        let defaultBackgroundColor = UIColor.white
        let defaultTitleColor = UIColor.mainDark
        let defaultShadowColor = UIColor(hex: 0xa0a0a0, alpha: 0.5)

        let callToActionBackgroundColor = UIColor.stepicGreen
        let callToActionTitleColor = UIColor.white
        let callToActionShadowColor = UIColor.clear
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

        let path = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.appearance.cornerRadius
        ).cgPath
        self.shadowLayer?.path = path
        self.shadowLayer?.shadowPath = path
    }

    private func updateAppearance() {
        self.titleLabel?.font = self.appearance.titleFont
        self.titleEdgeInsets = self.appearance.titleInsets

        self.shadowLayer?.removeFromSuperlayer()

        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowOffset = self.appearance.shadowOffset
        shadowLayer.shadowOpacity = self.appearance.shadowOpacity
        shadowLayer.shadowRadius = self.appearance.shadowRadius

        switch self.mode {
        case .default:
            self.setTitleColor(self.appearance.defaultTitleColor, for: .normal)

            shadowLayer.fillColor = self.appearance.defaultBackgroundColor.cgColor
            shadowLayer.shadowColor = self.appearance.defaultShadowColor.cgColor
        case .callToAction:
            self.setTitleColor(self.appearance.callToActionTitleColor, for: .normal)

            shadowLayer.fillColor = self.appearance.callToActionBackgroundColor.cgColor
            shadowLayer.shadowColor = self.appearance.callToActionShadowColor.cgColor
        }

        self.layer.insertSublayer(shadowLayer, at: 0)
        self.shadowLayer = shadowLayer
    }

    enum Mode {
        /// Classic white button
        case `default`
        /// Green button
        case callToAction
    }
}
