//
//  HTMLBuilder.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class HTMLBuilder: NSObject {
    private override init() {}
    static var sharedBuilder = HTMLBuilder()
    
    func buildHTMLStringWith(head head: String, body: String, addStepicFont : Bool = true) -> String {
        var res = "<html>\n"
        res += "<head>\n\(head)\n</head>\n"
        if !addStepicFont {
            res += "<body>\n\(body)\n</body>\n"
        } else {
            res += "<body>\n"
            res += "<font face=Verdana>\(body)</font>\n"
            res += "</body>\n"
        }
        res += "</html>"
        return res
    }
}
