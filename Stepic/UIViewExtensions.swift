//
//  UIViewExtensions.swift
//  Stepic
//
//  Created by Alexander Karpov on 04.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

extension UIView {
    func setRoundedBounds(width: CGFloat, color: UIColor = UIColor.white) {
        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
    func setRoundedCorners(cornerRadius radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor ) {
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth 
        self.layer.borderColor = borderColor.cgColor;
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

}
