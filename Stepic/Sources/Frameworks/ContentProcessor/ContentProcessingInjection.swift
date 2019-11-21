import Foundation
import WebKit

protocol ContentProcessingInjection: class {
    /// Script that will be injected to <head></head>
    var headScript: String { get }
    /// Script that will be injected after <body> tag
    var bodyHeadScript: String { get }
    /// Script that will be injected before <body> tag
    var bodyTailScript: String { get }

    func shouldInject(to code: String) -> Bool
}

extension ContentProcessingInjection {
    var headScript: String {
        return ""
    }

    var bodyHeadScript: String {
        return ""
    }

    var bodyTailScript: String {
        return ""
    }

    func shouldInject(to code: String) -> Bool {
        return true
    }
}

/// Injects WYSIWYG and Stepik CSS files
final class CommonStylesInjection: ContentProcessingInjection {
    var headScript: String {
        return Scripts.styles
    }
}

/// Injects meta-viewport
final class MetaViewportInjection: ContentProcessingInjection {
    var headScript: String {
        return Scripts.metaViewport
    }
}

/// Clickable images
final class ClickableImagesInjection: ContentProcessingInjection {
    var headScript: String {
        return Scripts.clickableImages
    }
}

/// Disable images callout on long tap
final class WebkitImagesCalloutDisableInjection: ContentProcessingInjection {
    var headScript: String {
        return Scripts.webkitCalloutDisable
    }
}

/// MathJax init script
final class MathJaxInjection: ContentProcessingInjection {
    var headScript: String {
        return Scripts.localTex
    }
}

/// Kotlin runnable code playground
final class KotlinRunnableSamplesInjection: ContentProcessingInjection {
    var headScript: String {
        return Scripts.kotlinRunnableSamples
    }

    func shouldInject(to code: String) -> Bool {
        return code.contains("<kotlin-runnable")
    }
}

/// Code syntax highlight with highlight.js
final class HightlightJSInjection: ContentProcessingInjection {
    var headScript: String {
        return Scripts.highlightJS
    }

    func shouldInject(to code: String) -> Bool {
        return code.contains("<code")
    }
}

/// Code syntax highlight with highlight.js
final class CustomAudioControlInjection: ContentProcessingInjection {
    var headScript: String {
        return Scripts.audioTagWrapper
    }

    var bodyTailScript: String {
        return Scripts.audioTagWrapperInit
    }

    func shouldInject(to code: String) -> Bool {
        return code.contains("<audio")
    }
}

/// Injects script that assigns font sizes.
final class FontSizeInjection: ContentProcessingInjection {
    private let fontSize: FontSize

    init(fontSize: FontSize) {
        self.fontSize = fontSize
    }

    var headScript: String {
        return Scripts.fontSize(self.fontSize)
    }
}

/// Injects script that assigns custom font sizes.
final class CustomFontSizeInjection: ContentProcessingInjection {
    private let bodyFontSize: Int
    private let h1FontSize: Int
    private let h2FontSize: Int
    private let h3FontSize: Int
    private let blockquoteFontSize: Int

    init(
        bodyFontSize: Int,
        h1FontSize: Int,
        h2FontSize: Int,
        h3FontSize: Int,
        blockquoteFontSize: Int
    ) {
        self.bodyFontSize = bodyFontSize
        self.h1FontSize = h1FontSize
        self.h2FontSize = h2FontSize
        self.h3FontSize = h3FontSize
        self.blockquoteFontSize = blockquoteFontSize
    }

    var headScript: String {
        return Scripts.fontSizeScript(
            bodyFontSizeString: "\(self.bodyFontSize)pt",
            h1FontSizeString: "\(self.h1FontSize)pt",
            h2FontSizeString: "\(self.h2FontSize)pt",
            h3FontSizeString: "\(self.h3FontSize)pt",
            blockquoteFontSizeString: "\(self.blockquoteFontSize)px"
        )
    }
}
