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
            return UIFont.Weight.thin.rawValue
        case .light:
            return UIFont.Weight.light.rawValue
        case .regular:
            return UIFont.Weight.regular.rawValue
        }
    }
}

enum StepikLabelColorMode {
    case dark, gray, light, blue

    var textColor: UIColor {
        switch self {
        case .dark:
            return UIColor.mainText
        case .light:
            return UIColor.white
        case .gray:
            return UIColor.lightGray
        case .blue:
            return UIColor.lightBlue
        }
    }
}

@IBDesignable
class StepikLabel: UILabel {

    var colorMode: StepikLabelColorMode = .dark {
        didSet {
            updateColorMode()
        }
    }

    private func updateColorMode() {
        self.textColor = colorMode.textColor
    }

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
        updateColorMode()
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
