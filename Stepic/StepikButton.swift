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
                setGrayStyle()
            }
        }
    }

    private func setGrayStyle() {
        if isGray {
            self.backgroundColor = UIColor(hex: 0x535366, alpha: 0.06)
            //mainText or mainDark here?
            self.setTitleColor(UIColor.mainText, for: .normal)
            setRoundedCorners(cornerRadius: 8, borderWidth: 0)
        } else {
            self.backgroundColor = UIColor(hex: 0x66cc66, alpha: 0.06)
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
        setGrayStyle()
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
