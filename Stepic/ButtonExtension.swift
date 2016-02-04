//
//  ButtonExtension.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

extension UIButton {
    override func setRoundedCorners(cornerRadius radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor ) {
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth 
        self.layer.borderColor = borderColor.CGColor;
        self.clipsToBounds = true
    }
    
    func setDisabledJoined() {
        let attributedTitle = NSAttributedString(string: Constants.alreadyJoinedCourseButtonText, attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        setAttributedTitle(attributedTitle, forState: .Normal )
        //enabled = false
        layer.borderColor = UIColor.grayColor().CGColor
        self.titleLabel?.textColor = UIColor.grayColor()
    }
    
    func setEnabledJoined() {
        let attributedTitle = NSAttributedString(string: Constants.joinCourseButtonText, attributes: [NSForegroundColorAttributeName : UIColor.stepicGreenColor()])
        setAttributedTitle(attributedTitle, forState: .Normal )
        //enabled = false
        layer.borderColor = UIColor.stepicGreenColor().CGColor
        self.titleLabel?.textColor = UIColor.stepicGreenColor()
    }
    
    func setStepicGreenStyle() {
        self.setRoundedCorners(cornerRadius: 8.0, borderWidth: 0.0, borderColor: UIColor.stepicGreenColor())
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.backgroundColor = UIColor.stepicGreenColor()
    }
    
    func setStepicWhiteStyle() {
        self.setRoundedCorners(cornerRadius: 8.0, borderWidth: 1.0, borderColor: UIColor.stepicGreenColor())
        self.setTitleColor(UIColor.stepicGreenColor(), forState: .Normal)
        self.backgroundColor = UIColor.whiteColor()
    }
    
    var isEnabledToJoin : Bool {
        return self.attributedTitleForState(.Normal)?.string != Constants.alreadyJoinedCourseButtonText
    }
    
}