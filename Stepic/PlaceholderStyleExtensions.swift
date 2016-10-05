//
//  PlaceholderStyleExtensions.swift
//  OstrenkiyPlaceholderView
//
//  Created by Alexander Karpov on 08.02.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

extension UIButton {
    func implementStyle(_ style: PlaceholderStyle.ButtonStyle) {
        self.titleLabel?.font = style.font
        self.setTitleColor(style.textColor, for: UIControlState())
        switch style.borderType {
        case .rect :
            self.setRoundedCorners(cornerRadius: 0.0, borderWidth: 1.0, borderColor: style.borderColor)
            break
        case .rounded:
            self.setRoundedCorners(cornerRadius: 8.0, borderWidth: 1.0, borderColor: style.borderColor)
            break
        case .none:
            break
        }
        self.backgroundColor = style.backgroundColor
    }
}

extension UILabel {
    func implementStyle(_ style: PlaceholderStyle.LabelStyle) {
        self.font = style.font
        self.textColor = style.textColor
        self.textAlignment = style.textAlignment
        self.lineBreakMode = style.lineBreakMode
    }
    
    class func heightForLabelWithText(_ text: String, style: PlaceholderStyle.LabelStyle, width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        
        label.numberOfLines = 0
        
        label.text = text
        
        label.implementStyle(style)
        label.sizeToFit()
        
        //        print(label.bounds.height)
        return label.bounds.height
    }

}
