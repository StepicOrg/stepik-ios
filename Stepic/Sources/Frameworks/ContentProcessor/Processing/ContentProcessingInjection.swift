import Foundation
import WebKit

protocol ContentProcessingInjection: AnyObject {
    /// Script that will be injected to <head></head>
    var headScript: String { get }
    /// Script that will be injected after <body> tag
    var bodyHeadScript: String { get }
    /// Script that will be injected before <body> tag
    var bodyTailScript: String { get }

    func shouldInject(to code: String) -> Bool
}

extension ContentProcessingInjection {
    var headScript: String { "" }

    var bodyHeadScript: String { "" }

    var bodyTailScript: String { "" }

    func shouldInject(to code: String) -> Bool { true }
}

/// Injects WYSIWYG and Stepik CSS files
final class CommonStylesInjection: ContentProcessingInjection {
    var headScript: String { Scripts.styles }
}

/// Injects meta-viewport
final class MetaViewportInjection: ContentProcessingInjection {
    var headScript: String { Scripts.metaViewport }
}

/// Clickable images
final class ClickableImagesInjection: ContentProcessingInjection {
    var headScript: String { Scripts.clickableImages }

    func shouldInject(to code: String) -> Bool {
        code.contains("<img")
    }
}

/// Disable images callout on long tap
final class WebkitImagesCalloutDisableInjection: ContentProcessingInjection {
    var headScript: String { Scripts.webkitCalloutDisable }
}

/// MathJax init script
final class MathJaxInjection: ContentProcessingInjection {
    var headScript: String { Scripts.localMathJax }

    func shouldInject(to code: String) -> Bool {
        code.filter { $0 == "$" }.count >= 2
            || (code.contains("\\[") && code.contains("\\]"))
            || (code.contains("math-tex"))
    }
}

/// Detect web scripts
final class WebScriptInjection: ContentProcessingInjection {
    func shouldInject(to code: String) -> Bool {
        code.contains("wysiwyg-") ||
        code.contains("<h1") ||
        code.contains("<h2") ||
        code.contains("<h3") ||
        code.contains("<h4") ||
        code.contains("<h5") ||
        code.contains("<h6") ||
        code.contains("<img") ||
        code.contains("<iframe") ||
        code.contains("<audio") ||
        code.contains("<table") ||
        code.contains("<div") ||
        code.contains("<blockquote")
    }
}

/// Kotlin runnable code playground
final class KotlinRunnableSamplesInjection: ContentProcessingInjection {
    var headScript: String { Scripts.localKotlinPlayground }

    func shouldInject(to code: String) -> Bool {
        code.contains("<kotlin-runnable")
    }
}

/// Code syntax highlight with highlight.js
final class HightlightJSInjection: ContentProcessingInjection {
    var headScript: String { Scripts.highlightJS }

    func shouldInject(to code: String) -> Bool {
        code.contains("<code")
    }
}

/// Code syntax highlight with highlight.js
final class CustomAudioControlInjection: ContentProcessingInjection {
    var headScript: String { Scripts.audioTagWrapper }

    var bodyTailScript: String { Scripts.audioTagWrapperInit }

    func shouldInject(to code: String) -> Bool {
        code.contains("<audio")
    }
}

/// Injects script that assigns font sizes.
final class FontSizeInjection: ContentProcessingInjection {
    private let fontSize: StepFontSize

    init(fontSize: StepFontSize) {
        self.fontSize = fontSize
    }

    var headScript: String { Scripts.fontSize(self.fontSize) }
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
        Scripts.fontSizeScript(
            bodyFontSizeString: "\(self.bodyFontSize)pt",
            h1FontSizeString: "\(self.h1FontSize)pt",
            h2FontSizeString: "\(self.h2FontSize)pt",
            h3FontSizeString: "\(self.h3FontSize)pt",
            blockquoteFontSizeString: "\(self.blockquoteFontSize)px"
        )
    }
}
