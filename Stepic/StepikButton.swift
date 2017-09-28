//
//  StepikButton.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

@IBDesignable
class StepikButton: UIButton {

    @IBInspectable
    var isGray: Bool = false {
        didSet {
            if isGray != oldValue {
                setGrayStyle()
            }
        }
    }

    private func setGrayStyle() {
        if isGray {
            //maybe move this to config?
            self.backgroundColor = UIColor(hex: 0x535366, alpha: 0.06)
            //mainText or mainDark here?
            self.setTitleColor(UIColor.mainText, for: .normal)
            setRoundedCorners(cornerRadius: 8, borderWidth: 0)
        } else {
            self.backgroundColor = UIColor(hex: 0x66cc66, alpha: 0.06)
            self.setTitleColor(UIColor.stepicGreen, for: .normal)
            setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreen)
        }
    }

    private func applyStyles() {
        setGrayStyle()
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
