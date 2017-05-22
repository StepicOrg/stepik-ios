//
//  StepReversedCardView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class StepReversedCardView: UIView {

    override func draw(_ rect: CGRect) {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hex: 0xCCCCCC).cgColor
    }
    
    override func layoutSubviews() {
        if let bgImage = UIImage(named: "stepic-pattern-grey") {
            self.backgroundColor = UIColor(patternImage: bgImage)
        }
    }
}
