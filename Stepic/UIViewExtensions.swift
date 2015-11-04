//
//  UIViewExtensions.swift
//  Stepic
//
//  Created by Alexander Karpov on 04.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

extension UIView {
    func setRoundedBounds(width width: CGFloat, color: UIColor = UIColor.whiteColor()) {
        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.borderWidth = width
        self.layer.borderColor = color.CGColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
}