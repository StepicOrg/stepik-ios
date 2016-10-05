//
//  Scripts.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct Scripts {
    
    fileprivate static func loadScriptWithKey(_ key: String) -> String {
        let path = Bundle.main.bundlePath
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
    
    fileprivate static var sizeReportScriptKey : String = "SizeReportScript"
    
    fileprivate static var texScriptKey : String = "TexScript"
    
    fileprivate static var localTexScriptKey : String = "LocalTexScript"

    fileprivate static var metaViewportKey : String = "MetaViewport"
    
    fileprivate static var mathJaxFinishedScriptKey: String = "MathJaxFinishScript"
    
    
    static var localTexScript : String {
        return "\(loadScriptWithKey(localTexScriptKey))\(mathJaxLocalPathScript)"
    }
    
    static var metaViewport : String {
        return "\(loadScriptWithKey(metaViewportKey))"
    }
    
    static var mathJaxFinishedScript: String {
        return "\(loadScriptWithKey(mathJaxFinishedScriptKey))"
    }
    
    fileprivate static var mathJaxLocalPathScript : String {
//        let path = NSBundle.mainBundle().pathForResource("MathJax", ofType: "js", inDirectory: "MathJax")!
        
        let scriptBeginning = "<script type=\"text/javascript\" src=\"MathJax/MathJax.js"
        let scriptEnding = "?config=TeX-AMS-MML_HTMLorMML\"></script>" //
        let script = "\(scriptBeginning)\(scriptEnding)"//\(path)
        return script
    }
}
