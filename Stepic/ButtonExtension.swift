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
        self.layer.borderColor = borderColor.cgColor;
        self.clipsToBounds = true
    }
    
    func setDisabledJoined() {
        let attributedTitle = NSAttributedString(string: Constants.alreadyJoinedCourseButtonText, attributes: [NSForegroundColorAttributeName : UIColor.gray])
        setAttributedTitle(attributedTitle, for: UIControlState() )
        //enabled = false
        layer.borderColor = UIColor.gray.cgColor
        self.titleLabel?.textColor = UIColor.gray
    }
    
    func setEnabledJoined() {
        let attributedTitle = NSAttributedString(string: Constants.joinCourseButtonText, attributes: [NSForegroundColorAttributeName : UIColor.stepicGreenColor()])
        setAttributedTitle(attributedTitle, for: UIControlState() )
        //enabled = false
        layer.borderColor = UIColor.stepicGreenColor().cgColor
        self.titleLabel?.textColor = UIColor.stepicGreenColor()
    }
    
    func setStepicGreenStyle() {
        self.setRoundedCorners(cornerRadius: 8.0, borderWidth: 0.0, borderColor: UIColor.stepicGreenColor())
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.backgroundColor = UIColor.stepicGreenColor()
    }
    
    func setStepicWhiteStyle() {
        self.setRoundedCorners(cornerRadius: 8.0, borderWidth: 1.0, borderColor: UIColor.stepicGreenColor())
        self.setTitleColor(UIColor.stepicGreenColor(), for: UIControlState())
        self.backgroundColor = UIColor.white
    }
    
    var isEnabledToJoin : Bool {
        return self.attributedTitle(for: UIControlState())?.string != Constants.alreadyJoinedCourseButtonText
    }
    
}
