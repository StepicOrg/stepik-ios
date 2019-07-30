//
//  UIViewExtensions.swift
//  Stepic
//
//  Created by Alexander Karpov on 04.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

extension UIView {
    func setRoundedBounds(width: CGFloat, color: UIColor = UIColor.white) {
        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

    func setRoundedCorners(cornerRadius radius: CGFloat, borderWidth: CGFloat? = nil, borderColor: UIColor? = nil ) {
        self.layer.cornerRadius = radius
        if let bw = borderWidth {
            self.layer.borderWidth = bw
        }
        if let bc = borderColor {
            self.layer.borderColor = bc.cgColor
        }
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

}
