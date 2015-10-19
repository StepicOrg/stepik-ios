//
//  ButtonExtension.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

extension UIButton {
    func setRoundedCorners(cornerRadius radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor ) {
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth 
        self.layer.borderColor = borderColor.CGColor;
        self.clipsToBounds = true
    }
    
    func setDisabledJoined() {
        let attributedTitle = NSAttributedString(string: Constants.alreadyJoinedCourseButtonText, attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        setAttributedTitle(attributedTitle, forState: .Normal )
        enabled = false
        layer.borderColor = UIColor.grayColor().CGColor
        self.titleLabel?.textColor = UIColor.grayColor()
    }
}