//
//  Scripts.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct Scripts {
    
    private static func loadScriptWithKey(key: String) -> String {
        let path = NSBundle.mainBundle().bundlePath
        let scriptsPlistPath = "\(path)/Scripts.plist"
        let plistData = NSDictionary(contentsOfFile: scriptsPlistPath)!
        return plistData[key] as! String
    }
    
    static var texScript : String {
        return loadScriptWithKey(texScriptKey)
    }
    
    static var sizeReportScript : String {
        return loadScriptWithKey(sizeReportScriptKey)
    }
    
    private static var sizeReportScriptKey : String = "SizeReportScript"
    
    private static var texScriptKey : String = "TexScript"
    
    private static var localTexScriptKey : String = "LocalTexScript"

    private static var metaViewportKey : String = "MetaViewport"
    
    private static var mathJaxFinishedScriptKey: String = "MathJaxFinishScript"
    
    
    static var localTexScript : String {
        return "\(loadScriptWithKey(localTexScriptKey))\(mathJaxLocalPathScript)"
    }
    
    static var metaViewport : String {
        return "\(loadScriptWithKey(metaViewportKey))"
    }
    
    static var mathJaxFinishedScript: String {
        return "\(loadScriptWithKey(mathJaxFinishedScriptKey))"
    }
    
    private static var mathJaxLocalPathScript : String {
//        let path = NSBundle.mainBundle().pathForResource("MathJax", ofType: "js", inDirectory: "MathJax")!
        
        let scriptBeginning = "<script type=\"text/javascript\" src=\"MathJax/MathJax.js"
        let scriptEnding = "?config=TeX-AMS-MML_HTMLorMML\"></script>" //
        let script = "\(scriptBeginning)\(scriptEnding)"//\(path)
        return script
    }
}