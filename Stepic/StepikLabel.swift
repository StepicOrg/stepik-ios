//
//  StepikLabel.swift
//  Stepic
//
//  Created by Ostrenkiy on 09.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

enum StepikLabelStyle {
    case thin, light, regular
    
    var weight: CGFloat {
        switch self {
        case .thin:
            return UIFontWeightThin
        case .light:
            return UIFontWeightLight
        case .regular:
            return UIFontWeightRegular
        }
    }
}

class StepikLabel: UILabel {
    
    func applyStyles() {
        self.textColor = UIColor.mainDarkColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
