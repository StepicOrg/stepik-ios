//
//  StepReversedCardView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class StepReversedCardView: UIView {
    
    var white: UIView?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        white = UIView(frame: bounds)
        backgroundColor = .white
        if white != nil {
            addSubview(white!)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let whiteView = white {
            whiteView.frame = bounds
            whiteView.backgroundColor = UIColor(patternImage: Images.patterns.gray)
        }
    }
}
