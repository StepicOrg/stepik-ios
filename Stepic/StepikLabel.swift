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

@IBDesignable
class StepikLabel: UILabel {

    @IBInspectable
    var isGray: Bool = false {
        didSet {
            if isGray {
                self.textColor = UIColor.lightGray
            } else {
                self.textColor = UIColor.mainText
            }
        }
    }

    private func applyStyles() {
        self.textColor = UIColor.mainText
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyles()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyStyles()
    }
}
