//
//  Styles.swift
//  OstrenkiyPlaceholderView
//
//  Created by Alexander Karpov on 08.02.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

struct PlaceholderStyle {
    struct LabelStyle {
        var font : UIFont = UIFont.systemFontOfSize(14)
        var textColor : UIColor = UIColor.lightGrayColor()
        var textAlignment : NSTextAlignment = NSTextAlignment.Center
        var lineBreakMode : NSLineBreakMode = NSLineBreakMode.ByWordWrapping
    }
    
    struct ButtonStyle {
        var font : UIFont = UIFont.systemFontOfSize(17)
        var borderType : BorderType = .None
        var borderColor : UIColor = UIColor.clearColor()
        var backgroundColor : UIColor = UIColor.clearColor()
        var textColor : UIColor = UIColor.blueColor()
    }
    
    var title = LabelStyle()
    var description = LabelStyle()
    var button = ButtonStyle()
}

var stepicPlaceholderStyle : PlaceholderStyle {
    var style = PlaceholderStyle()
    style.title.font = UIFont.boldSystemFontOfSize(18)
    style.button.borderType = .None
    style.button.borderColor = UIColor.stepicGreenColor()
    style.button.backgroundColor = UIColor.whiteColor()
    style.button.textColor = UIColor.stepicGreenColor()
    return style
}

enum BorderType {
    case None, Rounded, Rect
}
