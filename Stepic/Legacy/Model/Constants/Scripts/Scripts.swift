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
    private static let localMathJaxScriptKey = "LocalTexScript"
    private static let localKaTeXScriptKey = "LocalKaTeXScript"
    private static let metaViewportKey = "MetaViewport"
    private static let mathJaxFinishedScriptKey = "MathJaxFinishScript"
    private static let clickableImagesScriptKey = "ClickableImages"
    private static let localJQueryScriptKey = "localJQueryScript"
    private static let localKotlinPlaygroundScript = "localKotlinPlaygroundScript"
    private static let audioTagWrapperKey = "AudioTagWrapper"
    private static let audioTagWrapperInitKey = "AudioTagWrapperInit"
    private static let wysiwygStylesKey = "wysiwygCSSWrapper"
    private static let commonStylesKey = "contentCSSWrapper"
    private static let highlightJSKey = "highlightJS"
    private static let webkitCalloutDisableKey = "WebkitTouchCalloutDisable"

    static var localJQuery: String {
        self.loadScriptWithKey(self.localJQueryScriptKey)
    }

    static var localKotlinPlayground: String {
        self.loadScriptWithKey(self.localKotlinPlaygroundScript)
    }

    static var localMathJax: String {
        "\(self.loadScriptWithKey(self.localMathJaxScriptKey))\(self.mathJaxLocalPathScript)"
    }

    static var metaViewport: String {
        self.loadScriptWithKey(self.metaViewportKey)
    }

    static var mathJaxFinished: String {
        self.loadScriptWithKey(self.mathJaxFinishedScriptKey)
    }

    static var clickableImages: String {
        "\(self.localJQuery)\(self.loadScriptWithKey(self.clickableImagesScriptKey))"
    }

    static var audioTagWrapper: String {
        self.loadScriptWithKey(self.audioTagWrapperKey)
    }

    static var audioTagWrapperInit: String {
        self.loadScriptWithKey(self.audioTagWrapperInitKey)
    }

    static var styles: String {
        "\(self.loadScriptWithKey(self.wysiwygStylesKey))\(self.loadScriptWithKey(self.commonStylesKey))"
    }

    static var highlightJS: String {
        "\(self.loadScriptWithKey(self.highlightJSKey))"
    }

    static var webkitCalloutDisable: String {
        "\(self.loadScriptWithKey(self.webkitCalloutDisableKey))"
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
