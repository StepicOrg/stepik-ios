//
//  StepikButton.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

@IBDesignable
class StepikButton: UIButton {
    private static let bounceDuration: TimeInterval = 0.15
    private static let bounceScale: CGFloat = 0.95

    @IBInspectable
    var isGray: Bool = false {
        didSet {
            if self.isGray != oldValue {
                self.updateStyle()
            }
        }
    }

    var isLightBackground = true {
        didSet {
            if self.isLightBackground != oldValue {
                self.updateStyle()
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.bounce()
        }
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyStyles()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.applyStyles()
    }

    private func applyStyles() {
        self.updateStyle()
    }

    private func updateStyle() {
        if self.isGray {
            self.backgroundColor = self.isLightBackground
                ? UIColor.stepikLightSecondaryBackground
                : UIColor(hex6: 0x5d5d70, alpha: 1)
            self.setTitleColor(self.isLightBackground ? UIColor.stepikPrimaryText : UIColor.white, for: .normal)
            self.setRoundedCorners(cornerRadius: 8, borderWidth: 0)
        } else {
            self.backgroundColor = self.isLightBackground
                ? UIColor.stepikGreen.withAlphaComponent(0.1)
                : UIColor(hex6: 0x545a67, alpha: 1)
            self.setTitleColor(.stepikGreen, for: .normal)
            self.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: .stepikGreen)
        }
    }

    private func setAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(value: 1.3)
        animation.duration = 0.1
        animation.repeatCount = 0
        animation.autoreverses = true
        self.layer.add(animation, forKey: nil)
    }

    private func bounce() {
        var changeX: CGFloat = 1
        var changeY: CGFloat = 1

        if self.isHighlighted {
            changeX = Self.bounceScale
            changeY = Self.bounceScale
        }

        let bounceAnimation = {
            self.transform = CGAffineTransform(scaleX: changeX, y: changeY)
        }

        UIView.animate(withDuration: Self.bounceDuration, animations: bounceAnimation)
    }
}
