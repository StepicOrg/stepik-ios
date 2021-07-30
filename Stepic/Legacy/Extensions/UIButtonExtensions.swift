//
//  ButtonExtension.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

extension UIButton {
    func setRoundedCorners(cornerRadius radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }

    func setStepicGreenStyle() {
        self.setRoundedCorners(cornerRadius: 8.0, borderWidth: 0.0, borderColor: UIColor.stepikAccent)
        self.setTitleColor(UIColor.white, for: UIControl.State())
        self.backgroundColor = UIColor.stepikAccent
    }

    func setStepicWhiteStyle() {
        self.setRoundedCorners(cornerRadius: 8.0, borderWidth: 1.0, borderColor: UIColor.stepikAccent)
        self.setTitleColor(UIColor.stepikAccent, for: UIControl.State())
        self.backgroundColor = UIColor.white
    }
}
