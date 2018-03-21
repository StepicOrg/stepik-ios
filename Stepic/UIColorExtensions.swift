//
//  UIExtensions.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.08.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

extension UIColor {

    public convenience init(hex: Int) {
        self.init(hex:hex, alpha:1.0)
    }

    public convenience init(hex: Int, alpha: CGFloat) {
        let red = CGFloat((0xff0000 & hex) >> 16) / 255.0
        let green = CGFloat((0xff00 & hex) >> 8) / 255.0
        let blue = CGFloat(0xff & hex) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    //default color is black
    var hexString: String {

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let hexString = String(format: "%02X%02X%02X",
                               Int(red * 255.0),
                               Int(green * 255.0),
                               Int(blue * 255.0))
        return hexString
    }

    static let errorRed: UIColor = UIColor(hex: 0xff0033)

    class var stepicGreen: UIColor {
        return StepicApplicationsInfo.Colors.mainGreen
    }

    static let mainLight: UIColor = UIColor(hex: 0xf6f6f6)

    class var mainDark: UIColor {
        return StepicApplicationsInfo.Colors.mainDark
    }

    class var mainText: UIColor {
        return StepicApplicationsInfo.Colors.mainText
    }

    static let thirdColor: UIColor = UIColor(hex: 0x54a2ff)

    static let correctQuizBackground: UIColor = UIColor(hex: 0xE9F9E9)
    static let wrongQuizBackground: UIColor = UIColor(hex: 0xF5EBF2)
    static let peerReviewYellow: UIColor = UIColor(hex: 0xFFFAE9)

}
