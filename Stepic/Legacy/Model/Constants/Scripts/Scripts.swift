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
    private static let localKotlinPlaygroundScript = "localKotlinPlaygroundScript"
    private static let audioTagWrapperKey = "AudioTagWrapper"
    private static let audioTagWrapperInitKey = "AudioTagWrapperInit"
    private static let wysiwygStylesKey = "wysiwygCSSWrapper"
    private static let commonStylesKey = "contentCSSWrapper"
    private static let courseInfoStylesKey = "courseInfoCSSWrapper"
    private static let textColorScriptKey = "textColorScript"
    private static let highlightJSKey = "highlightJS"
    private static let webkitCalloutDisableKey = "WebkitTouchCalloutDisable"
    private static let fontSizeScriptKey = "FontSizeScript"

    static var localJQuery: String {
        self.loadScriptWithKey(self.localJQueryScriptKey)
    }

    static var localKotlinPlayground: String {
        self.loadScriptWithKey(self.localKotlinPlaygroundScript)
    }

    static var localTex: String {
        "\(self.loadScriptWithKey(self.localTexScriptKey))\(self.mathJaxLocalPathScript)"
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

    static var courseInfoStyles: String {
        self.loadScriptWithKey(self.courseInfoStylesKey)
    }

    static var highlightJS: String {
         "\(self.loadScriptWithKey(self.highlightJSKey))"
    }

    static var webkitCalloutDisable: String {
         "\(self.loadScriptWithKey(self.webkitCalloutDisableKey))"
    }

    static func textColor(color: UIColor) -> String {
        let script = self.loadScriptWithKey(self.textColorScriptKey)
        return script.replacingOccurrences(of: "######", with: "#\(color.hexString)")
    }

    /// Returns script that replaces font size variables with the provided ones at `stepikcontent.css`.
    static func fontSize(_ fontSize: StepFontSize) -> String {
        self.fontSizeScript(
            bodyFontSizeString: fontSize.body,
            h1FontSizeString: fontSize.h1,
            h2FontSizeString: fontSize.h2,
            h3FontSizeString: fontSize.h3,
            blockquoteFontSizeString: fontSize.blockquote
        )
    }

    /// Returns script that replaces font size variables with the provided ones at `stepikcontent.css`.
    /// Example: h1FontSizeString = 20pt, h2FontSizeString = 17pt, blockquoteFontSizeString = 16px
    static func fontSizeScript(
        bodyFontSizeString: String = StepFontSize.small.body,
        h1FontSizeString: String = StepFontSize.small.h1,
        h2FontSizeString: String = StepFontSize.small.h2,
        h3FontSizeString: String = StepFontSize.small.h3,
        blockquoteFontSizeString: String = StepFontSize.small.blockquote
    ) -> String {
        let script = self.loadScriptWithKey(self.fontSizeScriptKey)
        return script
            .replacingOccurrences(of: "##--body-font-size##", with: bodyFontSizeString)
            .replacingOccurrences(of: "##--h1-font-size##", with: h1FontSizeString)
            .replacingOccurrences(of: "##--h2-font-size##", with: h2FontSizeString)
            .replacingOccurrences(of: "##--h3-font-size##", with: h3FontSizeString)
            .replacingOccurrences(of: "##--blockquote-font-size##", with: blockquoteFontSizeString)
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
