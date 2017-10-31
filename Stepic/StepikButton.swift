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

    let bounceDuration: TimeInterval = 0.15
    let bounceScale: CGFloat = 0.95

    override var isHighlighted: Bool {
        didSet {
            bounce()
        }
    }

    private func bounce() {
        var changeX: CGFloat = 1
        var changeY: CGFloat = 1
        if isHighlighted {
            changeX = bounceScale
            changeY = bounceScale
        }
        let bounceAnimation = {
            self.transform = CGAffineTransform(scaleX: changeX, y: changeY)
        }
        UIView.animate(withDuration: bounceDuration, animations: bounceAnimation)
    }

    @IBInspectable
    var isGray: Bool = false {
        didSet {
            if isGray != oldValue {
                updateStyle()
            }
        }
    }

    var isLightBackground: Bool = true {
        didSet {
            if isLightBackground != oldValue {
                updateStyle()
            }
        }
    }

    private func updateStyle() {
        if isGray {
            self.backgroundColor = isLightBackground ? UIColor(hex: 0xf5f5f6, alpha: 1) : UIColor(hex: 0x5d5d70, alpha: 1)
            self.setTitleColor(isLightBackground ? UIColor.mainText : UIColor.white, for: .normal)
            setRoundedCorners(cornerRadius: 8, borderWidth: 0)
        } else {
            self.backgroundColor = isLightBackground ? UIColor(hex: 0xf6fcf6, alpha: 1) : UIColor(hex: 0x545a67, alpha: 1)
            self.setTitleColor(UIColor.stepicGreen, for: .normal)
            setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreen)
        }
    }

    private func setAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(value: 1.3)
        animation.duration = 0.1
        animation.repeatCount = 0
        animation.autoreverses = true
        layer.add(animation, forKey: nil)
    }

    private func applyStyles() {
        updateStyle()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyles()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyStyles()
    }
}
