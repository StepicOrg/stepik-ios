//
//  PlaceholderStyleExtensions.swift
//  OstrenkiyPlaceholderView
//
//  Created by Alexander Karpov on 08.02.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

extension UIButton {
    func implementStyle(style: PlaceholderStyle.ButtonStyle) {
        self.titleLabel?.font = style.font
        self.setTitleColor(style.textColor, forState: .Normal)
        switch style.borderType {
        case .Rect :
            self.setRoundedCorners(cornerRadius: 0.0, borderWidth: 1.0, borderColor: style.borderColor)
            break
        case .Rounded:
            self.setRoundedCorners(cornerRadius: 8.0, borderWidth: 1.0, borderColor: style.borderColor)
            break
        case .None:
            break
        }
        self.backgroundColor = style.backgroundColor
    }
}

extension UILabel {
    func implementStyle(style: PlaceholderStyle.LabelStyle) {
        self.font = style.font
        self.textColor = style.textColor
        self.textAlignment = style.textAlignment
        self.lineBreakMode = style.lineBreakMode
    }
    
    class func heightForLabelWithText(text: String, style: PlaceholderStyle.LabelStyle, width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.max))
        
        label.numberOfLines = 0
        
        label.text = text
        
        label.implementStyle(style)
        label.sizeToFit()
        
        //        print(label.bounds.height)
        return label.bounds.height
    }

}
