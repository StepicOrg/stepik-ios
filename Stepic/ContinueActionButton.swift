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
        let cornerRadius: CGFloat = 33.0
        let titleFont = UIFont.systemFont(ofSize: 16)
        let titleColor = UIColor.mainDark

        let backgroundColor = UIColor.white

        let shadowColor = UIColor(hex: 0xa0a0a0, alpha: 0.5)
        let shadowOffset = CGSize(width: 0, height: 1.3)
        let shadowOpacity: Float = 1.0
        let shadowRadius: CGFloat = 6.7

        let titleInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

final class ContinueActionButton: BounceButton {
    let appearance: Appearance

    private lazy var shadowLayer: CAShapeLayer = {
        let shadowLayer = CAShapeLayer()
        shadowLayer.fillColor = self.appearance.backgroundColor.cgColor

        shadowLayer.shadowColor = self.appearance.shadowColor.cgColor
        shadowLayer.shadowOffset = self.appearance.shadowOffset
        shadowLayer.shadowOpacity = self.appearance.shadowOpacity
        shadowLayer.shadowRadius = self.appearance.shadowRadius

        return shadowLayer
    }()

    init(frame: CGRect, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.titleLabel?.font = self.appearance.titleFont
        self.setTitleColor(self.appearance.titleColor, for: .normal)
        self.titleEdgeInsets = self.appearance.titleInsets
        self.layer.insertSublayer(self.shadowLayer, at: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.shadowLayer.path = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.appearance.cornerRadius
        ).cgPath
        self.shadowLayer.shadowPath = self.shadowLayer.path
    }
}
