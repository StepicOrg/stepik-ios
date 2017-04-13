//
//  StepControlButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class StepControlButton: UIButton {

    // TODO: add pressed state
    
    var shadowLayer: CAShapeLayer!
    
    override func draw(_ rect: CGRect) {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.clear
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: self.frame.height / 2).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            
            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize.zero
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 4
            
            layer.insertSublayer(shadowLayer, at: 0)
        }        
    }

}
