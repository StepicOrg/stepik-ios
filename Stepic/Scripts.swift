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

    static var texScript: String {
        return loadScriptWithKey(texScriptKey)
    }

    static var sizeReportScript: String {
        return loadScriptWithKey(sizeReportScriptKey)
    }

    fileprivate static let sizeReportScriptKey: String = "SizeReportScript"
    fileprivate static let texScriptKey: String = "TexScript"
    fileprivate static let localTexScriptKey: String = "LocalTexScript"
    fileprivate static let metaViewportKey: String = "MetaViewport"
    fileprivate static let mathJaxFinishedScriptKey: String = "MathJaxFinishScript"
    fileprivate static let clickableImagesScriptKey: String = "ClickableImages"
    fileprivate static let localJQueryScriptKey: String = "localJQueryScript"
    fileprivate static let audioTagWrapperKey: String = "AudioTagWrapper"
    fileprivate static let audioTagWrapperInitKey: String = "AudioTagWrapperInit"
    fileprivate static let kotlinRunnableSamplesKey: String = "KotlinRunnableSamples"
    fileprivate static let wysiwygStylesKey: String = "wysiwygCSSWrapper"
    fileprivate static let commonStylesKey: String = "contentCSSWrapper"
    fileprivate static let textColorScriptKey: String = "textColorScript"

    static var localJQuery: String {
        return loadScriptWithKey(localJQueryScriptKey)
    }

    static var localTex: String {
        return "\(loadScriptWithKey(localTexScriptKey))\(mathJaxLocalPathScript)"
    }

    static var metaViewport: String {
        return loadScriptWithKey(metaViewportKey)
    }

    static var mathJaxFinished: String {
        return loadScriptWithKey(mathJaxFinishedScriptKey)
    }

    static var clickableImages: String {
        return "\(localJQuery)\(loadScriptWithKey(clickableImagesScriptKey))"
    }

    static var audioTagWrapper: String {
        return loadScriptWithKey(audioTagWrapperKey)
    }

    static var audioTagWrapperInit: String {
        return loadScriptWithKey(audioTagWrapperInitKey)
    }

    static var kotlinRunnableSamples: String {
        return loadScriptWithKey(kotlinRunnableSamplesKey)
    }

    static var styles: String {
        return "\(loadScriptWithKey(wysiwygStylesKey))\(loadScriptWithKey(commonStylesKey))"
    }

    static func textColor(color: UIColor) -> String {
        let script = loadScriptWithKey(textColorScriptKey)
        return script.replacingOccurrences(of: "######", with: "#\(color.hexString)")
    }

    fileprivate static var mathJaxLocalPathScript: String {
        let scriptBeginning = "<script type=\"text/javascript\" src=\"MathJax/MathJax.js"
        let scriptEnding = "?config=TeX-AMS-MML_HTMLorMML\"></script>"
        let script = "\(scriptBeginning)\(scriptEnding)"
        return script
    }
}
