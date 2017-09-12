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
        var font: UIFont = UIFont.systemFont(ofSize: 14)
        var textColor: UIColor = UIColor.lightGray
        var textAlignment: NSTextAlignment = NSTextAlignment.center
        var lineBreakMode: NSLineBreakMode = NSLineBreakMode.byWordWrapping
    }

    struct ButtonStyle {
        var font: UIFont = UIFont.systemFont(ofSize: 17)
        var borderType: BorderType = .none
        var borderColor: UIColor = UIColor.clear
        var backgroundColor: UIColor = UIColor.clear
        var textColor: UIColor = UIColor.blue
    }

    var title = LabelStyle()
    var description = LabelStyle()
    var button = ButtonStyle()
}

var stepicPlaceholderStyle: PlaceholderStyle {
    var style = PlaceholderStyle()
    style.title.font = UIFont.boldSystemFont(ofSize: 18)
    style.button.borderType = .none
    style.button.borderColor = UIColor.mainDarkColor
    style.button.backgroundColor = UIColor.white
    style.button.textColor = UIColor.mainDarkColor
    return style
}

enum BorderType {
    case none, rounded, rect
}
