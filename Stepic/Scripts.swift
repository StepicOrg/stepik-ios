//
//  Scripts.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct Scripts {
    
    static var texScript : String {
        let path = NSBundle.mainBundle().bundlePath
        let scriptsPlistPath = "\(path)/Scripts.plist"
        let plistData = NSDictionary(contentsOfFile: scriptsPlistPath)!
        return plistData[texScriptKey] as! String
    }
    
    private static var texScriptKey : String = "TexScript"
}