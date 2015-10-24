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
    
    private var stepicStyleString : String {        
        var res : String = ""
        res += "<style>"
        res += "body{font-size: 12pt; font-family:Arial, Helvetica, sans-serif;}"
        res += "h1{font-size: 14pt; font-family:Arial, Helvetica, sans-serif;}"
        res += "h2{font-size: 16pt; font-family:Arial, Helvetica, sans-serif;}"
        res += "h3{font-size: 18pt; font-family:Arial, Helvetica, sans-serif;}"
        res += "</style>\n"
        return res
    }
    
    func buildHTMLStringWith(head head: String, body: String, addStepicFont : Bool = true) -> String {
        var res = "<html>\n"
        
        res += "<head>\n\(stepicStyleString + head)\n</head>\n"
        res += "<body>\n\(body)\n</body>\n"
        res += "</html>"
        return res
    }
}
