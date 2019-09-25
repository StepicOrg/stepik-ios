//
//  Scripts.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "Use ContentProcessor instead")
struct Scripts {
    private static let localTexScriptKey = "LocalTexScript"
    private static let localKaTeXScriptKey = "LocalKaTeXScript"
    private static let metaViewportKey = "MetaViewport"
    private static let mathJaxFinishedScriptKey = "MathJaxFinishScript"
    private static let clickableImagesScriptKey = "ClickableImages"
    private static let localJQueryScriptKey = "localJQueryScript"
    private static let audioTagWrapperKey = "AudioTagWrapper"
    private static let audioTagWrapperInitKey = "AudioTagWrapperInit"
    private static let kotlinRunnableSamplesKey = "KotlinRunnableSamples"
    private static let wysiwygStylesKey = "wysiwygCSSWrapper"
    private static let commonStylesKey = "contentCSSWrapper"
    private static let textColorScriptKey = "textColorScript"
    private static let highlightJSKey = "highlightJS"
    private static let webkitCalloutDisableKey = "WebkitTouchCalloutDisable"

    static var localJQuery: String {
        return loadScriptWithKey(localJQueryScriptKey)
    }

    static var localTex: String {
        return RemoteConfig.shared.newLessonAvailable
            ? loadScriptWithKey(localKaTeXScriptKey)
            : "\(loadScriptWithKey(localTexScriptKey))\(mathJaxLocalPathScript)"
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

    static var highlightJS: String {
        return "\(loadScriptWithKey(highlightJSKey))"
    }

    static var webkitCalloutDisable: String {
        return "\(loadScriptWithKey(webkitCalloutDisableKey))"
    }

    private static func loadScriptWithKey(_ key: String) -> String {
        let path = Bundle.main.bundlePath
        let scriptsPlistPath = "\(path)/Scripts.plist"
        let plistData = NSDictionary(contentsOfFile: scriptsPlistPath)!
        return plistData[key] as! String
    }

    private static var mathJaxLocalPathScript: String {
        let scriptBeginning = "<script type=\"text/javascript\" src=\"MathJax/MathJax.js"
        let scriptEnding = "?config=TeX-AMS-MML_HTMLorMML\"></script>"
        let script = "\(scriptBeginning)\(scriptEnding)"
        return script
    }
}
